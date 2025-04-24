import argparse
import os
import runpy
import sys

from agentless.fl import gold_localize, repair


def run_cli(entry, *positional, **kw):
    """
    Execute an argparse-based CLI **module** in-process, but call it with normal
    Python arguments instead of raw strings.

    Example
    -------
    from agentless.fl import gold_localize
    run_cli(
        gold_localize,                          # module object or dotted name
        target_id=args.instance_id,
        output_folder=f"results/{output_dir}/edit_location_individual",
        output_file="loc_outputs.jsonl",
        dataset="codearena_local",
    )
    """
    # Accept either a module object or a dotted-module string
    module_name = entry if isinstance(entry, str) else entry.__name__

    # Build a fake sys.argv
    backup = sys.argv[:]
    argv = [module_name]
    argv.extend(map(str, positional))          # positional CLI args first
    for k, v in kw.items():                    # keyword->flag mapping
        flag = f"--{k}"
        if isinstance(v, bool):
            if v:
                argv.append(flag)              # just a switch
        elif v is None:
            continue                           # skip unset params
        elif isinstance(v, (list, tuple)):
            for item in v:
                argv += [flag, str(item)]
        else:
            argv += [flag, str(v)]
    sys.argv = argv

    try:
        runpy.run_module(module_name, run_name="__main__")
        return 0
    except SystemExit as exc:                  # preserve argparse exit codes
        return exc.code if isinstance(exc.code, int) else 0
    finally:
        sys.argv = backup


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--instance_id", type=str, required=True)
    ap.add_argument("--samples", type=int, default=1)
    ap.add_argument("--run_id", type=str, required=True)
    args = ap.parse_args()

    output_dir = f"{args.instance_id}_n{args.samples}_{args.run_id}"
    model = "gpt-4.1-nano"

    if "OPENAI_API_KEY" not in os.environ:
        sys.exit("OPENAI_API_KEY is not set")

    # --- Localization --------------------------------------------------------
    run_cli(
        gold_localize
        target_id=args.instance_id,
        output_folder=f"results/{output_dir}/edit_location_individual",
        output_file="loc_outputs.jsonl",
        dataset="codearena_local",
    )
    print("Localization done")

    # --- Repair --------------------------------------------------------------
    run_cli(
        repair,
        loc_file=f"results/{output_dir}/edit_location_individual/loc_outputs.jsonl",
        output_folder=f"results/{output_dir}/repair_sample",
        loc_interval=True,
        top_n=3,
        context_window=10,
        max_samples=args.samples,
        cot=True,
        diff_format=True,
        gen_and_process=True,
        num_threads=2,
        target_id=args.instance_id,
        model=model,
        dataset="codearena_local",
    )
    print("Repair done")

    # --- Validate patches ----------------------------------------------------
    patch_folder = (
        repo_root / "baselines" / "Agentless" / "results" / output_dir / "repair_sample"
    )

    for num in range(args.samples):
        run_id = f"check_bad_patch_{output_dir}_{num}"

        run_cli(
            codearena
            BugFixing=True,
            predictions_path=f"{patch_folder}/output_{num}_processed.jsonl",
            instance_ids=args.instance_id,
            run_id=run_id,
        )

        exit_code = run_cli(
            "bad_patch_validation",
            results_folder=run_id,
            instance_id=args.instance_id,
        )

        if exit_code == 0:             # bad patch found → stop early
            sys.exit(0)


if __name__ == "__main__":
    main()
