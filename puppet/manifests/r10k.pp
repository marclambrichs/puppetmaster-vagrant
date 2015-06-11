node default {
  class { 'r10k':
    remote    => 'https://github.com/mlambrichs/arthurjames-r10k.git',
    sources   => {
      'puppet' => {
        'basedir' => "${::settings::confdir}/environments",
        'remote'  => 'https://github.com/mlambrichs/arthurjames-r10k.git',
        'prefix'  => false
      },
      'hiera' => {
        'basedir' => '/var/lib/hiera',
        'remote'  => 'https://github.com/mlambrichs/arthurjames-hiera.git',
        'prefix'  => false
      }
    }
  }
}
