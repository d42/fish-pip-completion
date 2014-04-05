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

    # aliased command
    set -l aliased (command git config --get "alias.$cmd[2]" ^ /dev/null | sed 's/ .*$//')
    if [ $argv[1] = "$aliased" ]
      return 0
    end
  end
  return 1
end

#keyword
complete --no-files -c pip -n '__fish_pip_needs_command' -a install -d 'Install packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a uninstall -d 'Uninstall packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a freeze -d 'Output installed packages in requirements format.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a list -d 'List installed packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a show -d 'Show information about installed packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a search -d 'Search PyPI for packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a wheel -d 'Build wheels from your requirements.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a zip -d 'DEPRECATED. Zip individual packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a unzip -d 'DEPRECATED. Unzip individual packages.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a bundle -d 'DEPRECATED. Create pybundles.'
complete --no-files -c pip -n '__fish_pip_needs_command' -a help -d 'Show help for commands.'


#general
#
complete --no-files -c pip -s h, -l help           -d 'Show help.'
complete --no-files -c pip -s v, -l verbose        -d 'Give more output. Option is additive, and can be used up to 3 times.'
complete --no-files -c pip -s V, -l version        -d 'Show version and exit.'
complete --no-files -c pip -s q, -l quiet          -d 'Give less output.'
complete --no-files -c pip -l log-file       -r    -d 'Path to a verbose non-appending log, that only logs failures. This log is active by default at /home/daz/.pip/pip.log.'
complete --no-files -c pip -l log            -r    -d 'Path to a verbose appending log. This log is inactive by default.'
complete --no-files -c pip -l proxy          -r    -d 'Specify a proxy in the form [user                                                                                      : passwd@]proxy.server                  : port.'
complete --no-files -c pip -l timeout        -r    -d 'Set the socket timeout (default 15 seconds).'
complete --no-files -c pip -l exists-action  -r    -d 'Default action when a path already exists                                                                              : (s)witch, (i)gnore, (w)ipe, (b)ackup.'
complete --no-files -c pip -l cert           -r    -d 'Path to alternate CA bundle.'


