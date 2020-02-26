#
# Cookbook Name:: nxlog
# Provider:: log_source
#
# Copyright (C) 2014 Simon Detheridge
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

def config_filename(name)
  "#{node['nxlog']['conf_dir']}/nxlog.conf.d/20_ip_#{name}.conf"
end

action :create do
  converge_by("Create #{new_resource}") do
    n = new_resource

    # common parameters
    params = []
    params << ['Module', n.input_module]
    params << ['Exec', n.exec] if n.exec
    params << ['InputType', n.input_type] if n.input_type
    params << ['FlowControl',
               n.flow_control.to_s.upcase] unless n.flow_control.nil?

    # module-specific parameters
    case n.input_module
    # undocumented in nxlog docs
    # when 'om_dbi'
    #   params << ['Driver', n.driver]
    #   params << ['SQL', n.sql]
    #   n.options.each do |option|
    #     params << ['Option', option]
    #   end

    when 'im_exec'
      params << ['Command', n.command]
      unless n.args.nil?
        n.args.each do |arg|
          params << ['Arg', arg]
        end
      end
      params << ['Restart', n.restart] unless n.restart.nil?

    when 'im_file'
      params << ['SavePos',
                 n.save_pos] unless n.save_pos.nil?
      params << ['ReadFromLast',
                 n.read_from_last] unless n.read_from_last.nil?
      params << ['Recursive',
                 n.recursive] unless n.recursive.nil?
      params << ['RenameCheck',
                 n.rename_check] unless n.rename_check.nil?
      params << ['CloseWhenIdle',
                 n.close_when_idle] unless n.close_when_idle.nil?
      params << ['PollInterval',
                 n.poll_interval] unless n.poll_interval.nil?
      params << ['DirCheckInterval',
                 n.dir_check_interval] unless n.dir_check_interval.nil?
      params << ['ActiveFiles',
                 n.active_files] unless n.active_files.nil?

      params << ['File', n.file =~ /["']/ ? n.file : "\"#{n.file}\""]

    when 'im_internal'
      # nothing to do!

    when 'im_kernel'
      # nothing to do!

    when 'im_mark'
      params << ['Mark', n.mark] unless n.mark.nil?
      params << ['MarkInterval', n.mark_interval] unless n.mark_interval.nil?

    when 'im_mseventlog'
      params << ['Sources', n.sources.join(',')] unless n.sources.nil?
      params << ['UTF8', n.utf8.to_s.upcase] unless n.utf8.nil?

    when 'im_msvistalog'
      params << ['Query', n.query] unless n.query.nil?
      params << ['Channel', n.channel] unless n.channel.nil?
      params << ['PollInterval', n.poll_interval] unless n.poll_interval.nil?

    when 'im_null'
      # nothing to do!

    when 'im_ssl'
      params << ['Host', n.host]
      params << ['Port', n.port]
      params << ['CertFile', n.cert_file] unless n.cert_file.nil?
      params << ['CertKeyFile', n.cert_key_file] unless n.cert_key_file.nil?
      params << ['KeyPass', n.key_pass] unless n.key_pass.nil?
      params << ['CAFile', n.ca_file] unless n.ca_file.nil?
      params << ['CADir', n.ca_dir] unless n.ca_dir.nil?
      params << ['CRLFile', n.crl_file] unless n.crl_file.nil?
      params << ['CRLDir', n.crl_dir] unless n.crl_dir.nil?

      params << ['AllowUntrusted',
                 n.allow_untrusted.to_s.upcase] unless n.allow_untrusted.nil?

    when 'im_tcp', 'im_udp'
      params << ['Host', n.host]
      params << ['Port', n.port]
      params << ['SockBufSize', n.sock_buf_size] unless n.sock_buf_size.nil?

    when 'im_uds'
      params << ['UDS', n.uds]

    else
      fail 'Tried to write nxlog config for unrecognised input module: ' +
        n.input_module

    end

    destinations = [*n.destination]
    destinations.map! { |v| v == 'defaults' ? '%DEFAULT_OUTPUTS%' : v }

    # create template with above parameters
    template config_filename(n.name) do
      cookbook 'nxlog'
      source 'resources/source.conf.erb'

      variables name: n.name,
                params: params,
                destinations: destinations

      notifies :restart, 'service[nxlog]', :delayed
    end
  end
end

action :delete do
  converge_by("Delete #{new_resource}") do
    template config_filename(new_resource.name) do
      cookbook new_resource.cookbook_name.to_s
      source 'resources/source.conf.erb'
      action :delete
      notifies :restart, 'service[nxlog]', :delayed
    end
  end
end
