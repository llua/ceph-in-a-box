#!/bin/bash -eu

PATH=/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:$PATH

# Do things that only need to be done when the box is first set up. if you're
# changing this, you need to be changing .kitchen.yml as well
# if ! rpm --quiet -q puppet-agent; then
if [ ! -e /etc/puppetlabs/r10k/r10k.yaml ]; then

    # Vagrant not always setting hostname
    if [[ $HOSTNAME = 'localhost.localdomain' ]]; then
        echo "Vagrant... Why you no set hostname.."
        exit 1
    fi

    # Commented out for now until we negate the need for a custom box
    #
    REL=$(rpm -q --qf "%{version}" -f /etc/redhat-release) REL=${REL%.*}

    yum -q -y install \
        "https://yum.puppetlabs.com/puppet-release-el-${REL}.noarch.rpm"
    yum -q -y install puppet-agent

    if ! source /etc/profile.d/puppet-agent.sh; then
      exit 1
    fi

    puppet module install puppet/r10k
    puppet apply -e "class {'r10k':
                       remote   => '/vagrant/',
                       cachedir => '/vagrant/.cache/',
                     }
                     package {'git':
                       ensure => present
                     }"

    cat <<\eof > /etc/puppetlabs/code/hiera.yaml
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: "untracked"
    path: "untracked.yaml"
eof
fi

# fix something for kitchen
if ! grep -qF '/vagrant/.cache/' /etc/puppetlabs/r10k/r10k.yaml; then
    puppet apply -e "class {'r10k': remote   => '/vagrant/', cachedir => '/vagrant/.cache/', }"
fi

git_branch="$(git --git-dir /vagrant/.git/ rev-parse --abbrev-ref HEAD)"
rsync --delete -a --exclude '\.*' --exclude 'modules' \
    /vagrant/ \
    "/etc/puppetlabs/code/environments/${git_branch}/"
r10k deploy environment -p "${git_branch}"
ruby /vagrant/scripts/mock_yaml.rb "$HOSTNAME"  > "/etc/puppetlabs/code/environments/${git_branch}/data/untracked.yaml"
puppet apply \
    --environment "${git_branch}" \
    --node_terminus=exec  \
    --external_nodes /vagrant/scripts/mock_enc.rb \
    -e ''
