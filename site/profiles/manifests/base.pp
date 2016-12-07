class profiles::base {
  include ::ntp
  package{['zsh','vim']:}
}
