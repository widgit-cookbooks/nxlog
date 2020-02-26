require_relative 'spec_helper'

describe 'nxlog::syslog' do
  let(:chef_run) do
    stub_command('test -L /dev/log').and_return(false)
    ChefSpec::SoloRunner.converge(described_recipe)
  end

  it 'removes the /dev/log device' do
    expect(chef_run).to run_bash('remove_log_node').with(
      code: 'rm -f /dev/log'
    )
  end

  it 'creates the /dev/log symlink' do
    expect(chef_run).to create_link('/dev/log').with(
      to: '/var/run/nxlog/devlog'
    )
  end

  it 'disables the rsyslog service' do
    expect(chef_run).to stop_service('rsyslog')
    expect(chef_run).to disable_service('rsyslog')
  end

  it 'creates a log source for the syslog device' do
    expect(chef_run).to create_nxlog_source('syslog').with(
      input_module: 'im_uds',
      uds: '/var/run/nxlog/devlog',
      exec: 'parse_syslog_bsd();',
      flow_control: false,
      destination: ['defaults']
    )
  end
end
