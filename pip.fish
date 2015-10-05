
function __fish_pip_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'pip' ]
    return 0
  end
  return 1
end

function __fish_pip_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

function __fish_pip_search_packages
  set cmd (commandline -op)
  if [ (count $cmd) -gt 2 ]
    set q $cmd[-1]
    set dir (dirname (status --current-filename))
    python $dir/pip_install_completion.py $q
  end
end

#keyword
complete --no-files  -c pip -n '__fish_pip_needs_command' -a install   -d 'Install packages.'
complete --no-files  -c pip -n '__fish_pip_needs_command' -a uninstall -d 'Uninstall packages.'
complete --no-files  -c pip -n '__fish_pip_needs_command' -a freeze    -d 'Output installed packages in requirements format.'
complete --no-files  -c pip -n '__fish_pip_needs_command' -a list      -d 'List installed packages.'
complete --no-files  -c pip -n '__fish_pip_needs_command' -a show      -d 'Show information about installed packages.'
complete --no-files  -c pip -n '__fish_pip_needs_command' -a search    -d 'Search PyPI for packages.'
complete --no-files  -c pip -n '__fish_pip_needs_command' -a wheel     -d 'Build wheels from your requirements.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a zip       -d 'DEPRECATED. Zip individual packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a unzip     -d 'DEPRECATED. Unzip individual packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a bundle    -d 'DEPRECATED. Create pybundles.'
complete --no-files  -c pip -n '__fish_pip_needs_command' -a help      -d 'Show help for commands.'


#general
complete --no-files  -c pip -s h,                         -l help      -d 'Show help.'
complete --no-files  -c pip -s v,                         -l verbose   -d 'Give more output. Option is additive, and can be used up to 3 times.'
complete --no-files  -c pip -s V,                         -l version   -d 'Show version and exit.'
complete --no-files  -c pip -s q,                         -l quiet     -d 'Give less output.'
complete --no-files  -c pip -l log-file                   -r           -d 'Path to a verbose non-appending log, that only logs failures. This log is active by default at ~/.pip/pip.log.'
complete --no-files  -c pip -l log                        -r           -d 'Path to a verbose appending log. This log is inactive by default.'
complete --no-files  -c pip -l proxy                      -r           -d 'Specify a proxy in the form [user: passwd@]proxy.server: port.'
complete --no-files  -c pip -l timeout                    -r           -d 'Set the socket timeout (default 15 seconds).'
complete --no-files  -c pip -l exists-action              -r           -d 'Default action when a path already exists: (s)witch, (i)gnore, (w)ipe, (b)ackup.'
complete --no-files  -c pip -l cert                       -r           -d 'Path to alternate CA bundle.'

complete --no-files -c pip	 -n '__fish_pip_using_command completion'	 -s b	 -l bash	 -d "Emit completion code for bash"
complete --no-files -c pip	 -n '__fish_pip_using_command completion'	 -s z	 -l zsh	 -d "Emit completion code for zsh"

complete --no-files -c pip	 -n '__fish_pip_using_command freeze'	 -s r	 -l requirement	 -d "Use the order in the given requirements file and its comments when generating output."
complete --no-files -c pip	 -n '__fish_pip_using_command freeze'	 -s f	 -l find-links	 -d "URL for finding packages, which will be added to the output."
complete --no-files -c pip	 -n '__fish_pip_using_command freeze'	 -s l	 -l local	 -d "If in a virtualenv that has global access, do not output globally-installed packages."
complete --no-files -c pip	 -n '__fish_pip_using_command freeze'	  -l user	 -d "Only output packages installed in user-site."


complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s c	 -l constraint	 -d "Constrain versions using the given constraints file. This option can be used multiple times."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s e	 -l editable	 -d "Install a project in editable mode (i.e. setuptools \"develop mode\") from a local project path or a VCS url."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s r	 -l requirement	 -d "Install from the given requirements file. This option can be used multiple times."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s b	 -l build	 -d "Directory to unpack packages into and build in."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s t	 -l target	 -d "Install packages into <dir>. By default this will not replace existing files/folders in <dir>. Use --upgrade to replace existing packages in <dir> with new versions."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s d	 -l download	 -d "Download packages into <dir> instead of installing them, regardless of what's already installed."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l download-cache	 -d "SUPPRESSHELP"
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l src	 -d "Directory to check out editable projects into. The default in a virtualenv is \"<venv path>/src\". The default for global installs is \"<current dir>/src\"."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s U	 -l upgrade	 -d "Upgrade all specified packages to the newest available version. This process is recursive regardless of whether a dependency is already satisfied."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l force-reinstall	 -d "When upgrading, reinstall all packages even if they are already up-to-date."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	 -s I	 -l ignore-installed	 -d "Ignore the installed packages (reinstalling instead)."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l no-deps	 -d "Don't install package dependencies."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l install-option	 -d "Extra arguments to be supplied to the setup.py install command (use like --install-option=\"--install-scripts=/usr/local/bin\"). Use multiple --install-option options to pass multiple options to setup.py install. If you are using an option with a directory path, be sure to use absolute path."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l global-option	 -d "Extra global options to be supplied to the setup.py call before the install command."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l user	 -d "Install to the Python user install directory for your platform. Typically ~/.local/, or %APPDATA%\Python on Windows. (See the Python documentation for site.USER_BASE for full details.)"
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l egg	 -d "Install packages as eggs, not 'flat', like pip normally does. This option is not about installing *from* eggs. (WARNING: Because this option overrides pip's normal install logic, requirements files may not behave as expected.)"
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l root	 -d "Install everything relative to this alternate root directory."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l compile	 -d "Compile py files to pyc"
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l no-compile	 -d "Do not compile py files to pyc"
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l use-wheel	 -d "SUPPRESSHELP"
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l no-use-wheel	 -d "Do not Find and prefer wheel archives when searching indexes and find-links locations. DEPRECATED in favour of --no-binary."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l no-binary	 -d "Do not use binary packages. Can be supplied multiple times, and each time adds to the existing value. Accepts either :all: to disable all binary packages, :none: to empty the set, or one or more package names with commas between them. Note that some packages are tricky to compile and may fail to install when this option is used on them."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l only-binary	 -d "Do not use source packages. Can be supplied multiple times, and each time adds to the existing value. Accepts either :all: to disable all source packages, :none: to empty the set, or one or more package names with commas between them. Packages without binary distributions will fail to install when this option is used on them."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l pre	 -d "Include pre-release and development versions. By default, pip only finds stable versions."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -l no-clean	 -d "Don't clean up build directories."
complete --no-files -c pip	 -n '__fish_pip_using_command install'	  -a '(__fish_pip_search_packages)'	 -d "Package"

complete --no-files -c pip	 -n '__fish_pip_using_command list'	 -s o	 -l outdated	 -d "List outdated packages (excluding editables)"
complete --no-files -c pip	 -n '__fish_pip_using_command list'	 -s u	 -l uptodate	 -d "List uptodate packages (excluding editables)"
complete --no-files -c pip	 -n '__fish_pip_using_command list'	 -s e	 -l editable	 -d "List editable projects."
complete --no-files -c pip	 -n '__fish_pip_using_command list'	 -s l	 -l local	 -d "If in a virtualenv that has global access, do not list globally-installed packages."
complete --no-files -c pip	 -n '__fish_pip_using_command list'	  -l user	 -d "Only output packages installed in user-site."
complete --no-files -c pip	 -n '__fish_pip_using_command list'	  -l pre	 -d "Include pre-release and development versions. By default, pip only finds stable versions."

complete --no-files -c pip	 -n '__fish_pip_using_command search'	  -l index	 -d "Base URL of Python Package Index (default %default)"

complete --no-files -c pip	 -n '__fish_pip_using_command show'	 -s f	 -l files	 -d "Show the full list of installed files for each package."

complete --no-files -c pip	 -n '__fish_pip_using_command uninstall'	 -s r	 -l requirement	 -d "Uninstall all the packages listed in the given requirements file.  This option can be used multiple times."
complete --no-files -c pip	 -n '__fish_pip_using_command uninstall'	 -s y	 -l yes	 -d "Don't ask for confirmation of uninstall deletions."
complete --no-files -c pip	 -n '__fish_pip_using_command uninstall'	 -a '(__fish_pip_list_packages)'	 -d "Package"

complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	 -s w	 -l wheel-dir	 -d "Build wheels into <dir>, where the default is '<cwd>/wheelhouse'."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l use-wheel	 -d "SUPPRESSHELP"
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l no-use-wheel	 -d "Do not Find and prefer wheel archives when searching indexes and find-links locations. DEPRECATED in favour of --no-binary."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l no-binary	 -d "Do not use binary packages. Can be supplied multiple times, and each time adds to the existing value. Accepts either :all: to disable all binary packages, :none: to empty the set, or one or more package names with commas between them. Note that some packages are tricky to compile and may fail to install when this option is used on them."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l only-binary	 -d "Do not use source packages. Can be supplied multiple times, and each time adds to the existing value. Accepts either :all: to disable all source packages, :none: to empty the set, or one or more package names with commas between them. Packages without binary distributions will fail to install when this option is used on them."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l build-option	 -d "Extra arguments to be supplied to 'setup.py bdist_wheel'."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	 -s c	 -l constraint	 -d "Constrain versions using the given constraints file. This option can be used multiple times."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	 -s e	 -l editable	 -d "Install a project in editable mode (i.e. setuptools \"develop mode\") from a local project path or a VCS url."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	 -s r	 -l requirement	 -d "Install from the given requirements file. This option can be used multiple times."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l download-cache	 -d "SUPPRESSHELP"
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l src	 -d "Directory to check out editable projects into. The default in a virtualenv is \"<venv path>/src\". The default for global installs is \"<current dir>/src\"."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l no-deps	 -d "Don't install package dependencies."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	 -s b	 -l build	 -d "Directory to unpack packages into and build in."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l global-option	 -d "Extra global options to be supplied to the setup.py call before the 'bdist_wheel' command."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l pre	 -d "Include pre-release and development versions. By default, pip only finds stable versions."
complete --no-files -c pip	 -n '__fish_pip_using_command wheel'	  -l no-clean	 -d "Don't clean up build directories."

