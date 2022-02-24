
# Script taken from https://github.com/labapart/cross_sysroot
# Licensed under GNU GPL 3.0 https://www.gnu.org/licenses/gpl-3.0.en.html or something

import logging
import os
import re
import sys
from os.path import relpath

pkconfig_line_is_prefix = re.compile(r"^prefix=(.*)\n$")



def fix_symbolic_link(root, path, file_path):
    """Fix symbol link file that does point to an absolute address not valid in the context of sysroot."""
    if os.path.islink(file_path):
        linkto = os.readlink(file_path)
        linkto_fullpath = os.path.join(path, linkto)

        if linkto.startswith("/"):
            linkto_rooted = os.path.join(root, "." + linkto)
            new_source = relpath(linkto_rooted, os.path.dirname(file_path))
#            logging.warning ("LINK:    %s %s %s %s", file_path, linkto, linkto_rooted, new_source)
            if os.path.isfile(os.path.join(path, new_source)):
                logging.info("Fix link for %s (from %s)", new_source, file_path)
                os.remove(file_path)
                os.symlink(new_source, file_path)
            else:
                logging.warning("Could not fix symbolic link: %s -> %s", file_path, new_source)
        elif not os.path.isfile(linkto_fullpath):
            logging.error("Could not fix symbolic link: %s -> %s", file_path, linkto_fullpath)


def patch_pkg_config(root, path, file_path):
    """Patch package configuration file '.pc' to use the correct path."""
    # Remove unused argument
    del path

    if not file_path.endswith('.pc'):
        return

    with open(file_path, "r+") as f:
        pkg_config_data = ""

        line = f.readline()
        while line:
            is_prefix = pkconfig_line_is_prefix.findall(line)
            if is_prefix:
                line = "prefix=%s%s\n" % (root, is_prefix[0])

            pkg_config_data += line
            line = f.readline()

        f.seek(0)
        f.write(pkg_config_data)
        f.truncate()


def fixup_sysroot(sysroot):
    """Fixup sysroot that might have broken symbolic link."""
    for root, directories, files in os.walk(sysroot):
        # Remove unused argument
        del directories

        for file in files:
            file_path = os.path.join(root, file)

            fix_symbolic_link(sysroot, root, file_path)
            # patch_pkg_config(sysroot, root, file_path)


fixup_sysroot (sys.argv[1])
