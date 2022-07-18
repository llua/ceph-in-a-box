class profiles::base {
  include ::chrony
  package{['zsh','vim']:}
}
