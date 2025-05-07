import datasets

import json

with open('../../data/codearena_instances.json', 'r') as f:
    data = json.load(f)

with open('../../data/java_instances.json', 'r') as f:
    java_data = json.load(f)

class LocalData(datasets.GeneratorBasedBuilder):
    VERSION = datasets.Version("1.0.0")

    def _info(self):
        return datasets.DatasetInfo(
            description="Loading local codearena instances",
            features=datasets.Features({
                "repo": datasets.Value("string"),
                "instance_id": datasets.Value("string"),
                "base_commit": datasets.Value("string"),
                "patch": datasets.Value("string"),
                "test_patch": datasets.Value("string"),
                "problem_statement": datasets.Value("string"),
                "hints_text": datasets.Value("string"),
                "created_at": datasets.Value("string"),
                "version": datasets.Value("string"),
                "FAIL_TO_PASS": datasets.Value("string"),
                "PASS_TO_PASS": datasets.Value("string"),
                "environment_setup_commit": datasets.Value("string"),
                "bad_patch": datasets.Value("string"),
                "bad_patch_author": datasets.Value("string"),
                "Review": datasets.Value("string"),
                "Review_Author": datasets.Value("string"),
            })
        )

    def _split_generators(self, dl_manager):
        # Only one split: "test"
        return [
            datasets.SplitGenerator(
                name=datasets.Split.TEST,
                gen_kwargs={"data": data}
            )
        ]

    def _generate_examples(self, data):
        # Yield examples using index as key
        for idx, record in enumerate(data):
            yield idx, record
