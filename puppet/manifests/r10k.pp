node default {
  class { 'r10k':
    remote    => 'git@cassandra.melange-it.nl:/var/opt/git/generic/r10k.git',
    sources   => {
      'puppet' => {
        'basedir' => "${::settings::confdir}/environments",
        'remote'  => 'git@cassandra.melange-it.nl:/var/opt/git/generic/r10k.git',
        'prefix'  => false
      },
      'hiera' => {
        'basedir' => "/var/lib/hiera",
        'remote'  => 'git@cassandra.melange-it.nl:/var/opt/git/generic/hiera.git',
        'prefix'  => false
      }
    }
  }
}
