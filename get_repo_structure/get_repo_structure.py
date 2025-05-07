import argparse
import ast
import json
import os
import subprocess
import uuid

import pandas as pd
from tqdm import tqdm


def get_repo_folder(repo_name):
    """Extract the repository folder name from the full repository path.

    :param repo_name: The full repository path (e.g. 'django/django')
    :return: The repository folder name (e.g. 'django')
    """
    return repo_name.split('/')[-1]


def checkout_commit(repo_path, commit_id):
    """Checkout the specified commit in the given local git repository.
    :param repo_path: Path to the local git repository
    :param commit_id: Commit ID to checkout
    :return: None
    """
    try:
        # Change directory to the provided repository path and checkout the specified commit
        print(f"Checking out commit {commit_id} in repository at {repo_path}...")
        subprocess.run(["git", "-C", repo_path, "checkout", commit_id], check=True)
        print("Commit checked out successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running git command: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def clone_repo(repo_name, repo_playground):
    repo_folder = get_repo_folder(repo_name)
    try:
        print(
            f"Cloning repository from https://github.com/{repo_name}.git to {repo_playground}/{repo_folder}..."
        )
        subprocess.run(
            [
                "git",
                "clone",
                f"https://github.com/{repo_name}.git",
                f"{repo_playground}/{repo_folder}",
            ],
            check=True,
        )
        print("Repository cloned successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running git command: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def get_project_structure_from_scratch(
    repo_name, commit_id, instance_id, repo_playground, language='python',
):
    # Generate a temperary folder and add uuid to avoid collision
    repo_playground = os.path.join(repo_playground, str(uuid.uuid4()))

    # assert playground doesn't exist
    assert not os.path.exists(repo_playground), f"{repo_playground} already exists"

    # create playground
    os.makedirs(repo_playground)

    clone_repo(repo_name, repo_playground)
    checkout_commit(f"{repo_playground}/{get_repo_folder(repo_name)}", commit_id)
    structure = create_structure(f"{repo_playground}/{get_repo_folder(repo_name)}", language)
    # clean up
    subprocess.run(
        ["rm", "-rf", f"{repo_playground}/{get_repo_folder(repo_name)}"], check=True
    )
    d = {
        "repo": repo_name,
        "base_commit": commit_id,
        "structure": structure,
        "instance_id": instance_id,
    }
    return d


def parse_java_file(file_path, file_content=None):
    """Parse a Java file. Currently only file content is supported.
    :param file_path: Path to the Python file.
    :return: Class names, function names, and file contents
    """
    if file_content is None:
        try:
            with open(file_path, "r") as file:
                file_content = file.read()
        except Exception as e:  # Catch all types of exceptions
            print(f"Error in java file {file_path}: {e}")
            return [], [], ""

    return [], [], file_content.splitlines()

def parse_file(file_path, file_content=None, language='python'):
    if language == 'python':
        return parse_python_file(file_path, file_content)
    elif language == 'java':
        return parse_java_file(file_path, file_content)
    else:
        raise ValueError(f"Unsupported language: {language}")


def parse_python_file(file_path, file_content=None):
    assert 0, 'should not be called'
    """Parse a Python file to extract class and function definitions with their line numbers.
    :param file_path: Path to the Python file.
    :return: Class names, function names, and file contents
    """
    if file_content is None:
        try:
            with open(file_path, "r") as file:
                file_content = file.read()
                parsed_data = ast.parse(file_content)
        except Exception as e:  # Catch all types of exceptions
            print(f"Error in file {file_path}: {e}")
            return [], [], ""
    else:
        try:
            parsed_data = ast.parse(file_content)
        except Exception as e:  # Catch all types of exceptions
            print(f"Error in file {file_path}: {e}")
            return [], [], ""

    class_info = []
    function_names = []
    class_methods = set()

    for node in ast.walk(parsed_data):
        if isinstance(node, ast.ClassDef):
            methods = []
            for n in node.body:
                if isinstance(n, ast.FunctionDef):
                    methods.append(
                        {
                            "name": n.name,
                            "start_line": n.lineno,
                            "end_line": n.end_lineno,
                            "text": file_content.splitlines()[
                                n.lineno - 1 : n.end_lineno
                            ],
                        }
                    )
                    class_methods.add(n.name)
            class_info.append(
                {
                    "name": node.name,
                    "start_line": node.lineno,
                    "end_line": node.end_lineno,
                    "text": file_content.splitlines()[
                        node.lineno - 1 : node.end_lineno
                    ],
                    "methods": methods,
                }
            )
        elif isinstance(node, ast.FunctionDef) and not isinstance(
            node, ast.AsyncFunctionDef
        ):
            if node.name not in class_methods:
                function_names.append(
                    {
                        "name": node.name,
                        "start_line": node.lineno,
                        "end_line": node.end_lineno,
                        "text": file_content.splitlines()[
                            node.lineno - 1 : node.end_lineno
                        ],
                    }
                )

    return class_info, function_names, file_content.splitlines()


def create_structure(directory_path, language='python'):
    """Create the structure of the repository directory by parsing Python files.
    :param directory_path: Path to the repository directory.
    :return: A dictionary representing the structure.
    """
    structure = {}

    for root, _, files in os.walk(directory_path):
        repo_name = os.path.basename(directory_path)
        relative_root = os.path.relpath(root, directory_path)
        if relative_root == ".":
            relative_root = repo_name
        curr_struct = structure
        for part in relative_root.split(os.sep):
            if part not in curr_struct:
                curr_struct[part] = {}
            curr_struct = curr_struct[part]
        for file_name in files:
            if language == 'python' and file_name.endswith(".py"):
                file_path = os.path.join(root, file_name)
                class_info, function_names, file_lines = parse_python_file(file_path)
                curr_struct[file_name] = {
                    "classes": class_info,
                    "functions": function_names,
                    "text": file_lines,
                }
            elif language == 'java' and file_name.endswith('.java'):
                file_path = os.path.join(root, file_name)
                class_info, function_names, file_lines = parse_java_file(file_path)
                curr_struct[file_name] = {
                    "classes": class_info,
                    "functions": function_names,
                    "text": file_lines,
                }
            else:
                curr_struct[file_name] = {}

    return structure


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--datapath", help="Path to the data file", default="./instances.csv"
    )
    parser.add_argument("--repo_playground", help="Path to the repo playground", required=True)
    parser.add_argument("--output_path", help="Output file path", required=True)
    args = parser.parse_args()

    repo_playground = args.repo_playground

    df = pd.read_csv(args.datapath)
    repos = df["repo"].unique()
    print(f"Found {len(repos)} repos: {repos}")

    all_structures = []
    index = 0

    for _, row in tqdm(df.iterrows(), total=len(df)):
        repo = row["repo"]
        repo_commit = row["base_commit"]
        instance_id = row["instance_id"]
        try:
            print(f"Processing {repo} at commit {repo_commit} for instance {instance_id}")
            # get the repo structure from scratch
            d = get_project_structure_from_scratch(
                repo, repo_commit, instance_id, repo_playground
            )
            all_structures.append(d)
        except Exception as e:
            print(f"Failed to process {repo} at commit {repo_commit} with error: {e}")

    with open(args.output_path, "w") as f:
        json.dump(all_structures, f, indent=2)


if __name__ == "__main__":
    main()
