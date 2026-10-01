"""Delete one /tmp entry without following parent or directory symlinks."""

import os
import shutil
import stat
import sys
from contextlib import ExitStack
from pathlib import Path

# This is the confinement boundary, not a predictable temporary file.
TEMP_ROOT = Path("/tmp")  # noqa: S108


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit("usage: pi-tmp-rm /tmp/<file-or-directory> (one path, no flags)")
    try:
        root = TEMP_ROOT.resolve(strict=True)
        path = Path(sys.argv[1])
        base = next((base for base in (TEMP_ROOT, root) if path.is_relative_to(base)), None)
        if base is None:
            raise ValueError("only absolute paths inside /tmp are allowed")
        parts = path.relative_to(base).parts
        if not parts or ".." in parts:
            raise ValueError("refusing the temp root or parent traversal")
        if not shutil.rmtree.avoids_symlink_attacks:
            raise RuntimeError("this platform lacks symlink-safe directory deletion")

        # Open parents without following links; a replacement symlink cannot
        # redirect deletion. rmtree also refuses to follow links in the tree.
        flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW
        with ExitStack() as stack:
            parent = os.open(root, flags)
            stack.callback(os.close, parent)
            for part in parts[:-1]:
                parent = os.open(part, flags, dir_fd=parent)
                stack.callback(os.close, parent)
            entry = os.stat(parts[-1], dir_fd=parent, follow_symlinks=False)
            if stat.S_ISDIR(entry.st_mode):
                shutil.rmtree(parts[-1], dir_fd=parent)
            else:
                os.unlink(parts[-1], dir_fd=parent)
    except (OSError, ValueError, RuntimeError) as error:
        sys.exit(f"pi-tmp-rm: {error}")


if __name__ == "__main__":
    main()
