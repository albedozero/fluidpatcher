#!/bin/bash

inform() {
  echo -e "$(tput setaf 6)$1$(tput sgr0)"
}
warning() {
  echo -e "$(tput setaf 3)$1$(tput sgr0)"
}

sleep 1

warning "This link is outdated."
inform "To install the active version of the squishbox software, use the command:"
echo "curl -sL geekfunklabs.com/squishbox | bash"
exit
