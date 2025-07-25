import argparse
import json
import os
from datasets import load_dataset
import re
from collections import defaultdict
from typing import Dict, List

_HUNK_RE = re.compile(r'^@@\s*-(\d+)(?:,\d+)?\s+\+(\d+)(?:,\d+)?\s*@@\s*(.*)$')
_HUNK_RE_2 = re.compile(r'^@@\s*-\d+(?:,\d+)?\s+\+(\d+)(?:,(\d+))?\s*@@')

_DEF_RE = re.compile(r'\bdef\s+([A-Za-z_]\w*)\s*\(')


def _extract_func_name(context: str) -> str:
    """Best‑effort grab of the function/class name from a hunk header tail."""
    if not context:
        return "unknown"
    m = _DEF_RE.search(context)
    if m:
        return m.group(1)
    #  fallbacks: header might just contain the symbol
    return context.strip().split()[0] or "unknown"


def files_and_funcs_from_patch(diff_text: str) -> Dict[str, List[str]]:
    """
    Given a unified‑diff patch file, return a `found_edit_locs`‑style dict:
        {
            "some/file.py": ["\nfunction: foo\nline: 42", ...],
            ...
        }
    """
    out: Dict[str, List[str]] = defaultdict(list)

    current_file = None
    for line in diff_text.splitlines():
        if line.startswith("diff --git"):
            # diff --git a/oldpath b/newpath  → take the b/ path
            parts = line.split()
            if len(parts) >= 4:
                current_file = parts[3][2:]  # strip leading "b/"
            continue

        if current_file is None or not line.startswith("@@"):
            continue

        m = _HUNK_RE.match(line)
        if not m:
            continue

        new_start = int(m.group(2))
        context = m.group(3)
        func_name = _extract_func_name(context)

        entry = f"\nfunction: {func_name}\nline: {new_start}"
        if entry not in out[current_file]:
            out[current_file].append(entry)

    return out


def get_edit_locs(patch_text: str, include_fn_name: bool = False, one_file: bool = False) -> Dict[str, List[str]]:
    if include_fn_name:
        return files_and_funcs_from_patch(patch_text)

    out: Dict[str, List[str]] = defaultdict(list)
    current_file = None
    for line in patch_text.splitlines():
        if line.startswith("diff --git"):
            parts = line.split()
            if len(parts) >= 4:
                current_file = parts[3][2:]  # strip "b/"
            continue
        if current_file is None or not line.startswith("@@"):
            continue
        m = _HUNK_RE_2.match(line)
        if not m:
            continue
        start = int(m.group(1))
        count = int(m.group(2)) if m.group(2) else 1
        end = start + count - 1
        entry = f"\nline: {start}\nline: {end}"
        if entry not in out[current_file]:
            out[current_file].append(entry)

    if one_file:
        # just the first file and its locs
        k = list(out.keys())[0]
        return {k: out[k]}

    return dict(out)


def gold_localize(args):
    swe_bench_data = load_dataset(args.dataset, split="test")
    try:
        task = [x for x in swe_bench_data if x["instance_id"] == args.target_id][0]
    except IndexError:
        print(f"Instance ID {args.target_id} not found in dataset {args.dataset}.")
        print("Available instance IDs:")
        for x in swe_bench_data:
            print(f" - {x['instance_id']}")
        return
    patch_text = task["patch"]
    changed_files = get_changed_files(patch_text)
    found_edit_locs = get_edit_locs(patch_text, include_fn_name=args.include_fn_name)

    output = {
        "instance_id": args.target_id,
        "found_files": changed_files,
        "found_edit_locs": found_edit_locs,
    }

    with open(args.output_file, 'w') as f:
        f.write(json.dumps(output))


def get_changed_files(patch: str) -> list[str]:
    """
    Extract file paths changed in a unified‑diff/patch string.
    """
    files = []
    for line in patch.splitlines():
        if line.startswith("diff --git"):
            # format: diff --git a/<path> b/<path>
            path = line.split()[2][2:]  # strip leading "a/"
            if path not in files:
                files.append(path)
    return files


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--output_folder", type=str, required=True)
    parser.add_argument("--output_file", type=str, default="loc_outputs.jsonl")
    parser.add_argument("--include_fn_name", action="store_true", default=False)
    parser.add_argument("--target_id", type=str)
    parser.add_argument(
        "--dataset",
        type=str,
        default="princeton-nlp/SWE-bench_Lite",
        help="Current supported dataset for evaluation",
    )

    args = parser.parse_args()
    args.output_file = os.path.join(args.output_folder, args.output_file)

    os.makedirs(os.path.join(args.output_folder, "localization_logs"), exist_ok=True)
    os.makedirs(args.output_folder, exist_ok=True)

    # write the arguments
    with open(f"{args.output_folder}/args.json", "w") as f:
        json.dump(vars(args), f, indent=4)

    gold_localize(args)


if __name__ == "__main__":
    main()
