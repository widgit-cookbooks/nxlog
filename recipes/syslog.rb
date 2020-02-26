#
# Cookbook Name:: nxlog
# Recipe:: papertrail
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

include_recipe 'nxlog::default'

if node['platform_family'] == 'windows'
  Chef::Application.fatal!('Syslog recipe is not supported on Windows')
end

old_logger = node['nxlog']['syslog']['logger_disable']

service old_logger do
  action [:stop, :disable]
  only_if { old_logger }
end

destinations = [node['nxlog']['syslog']['destinations']].flatten.map do |d|
  d == 'defaults' ? 'defaults' : d
end

bash 'remove_log_node' do
  code 'rm -f /dev/log'
  not_if 'test -L /dev/log'
end

link '/dev/log' do
  to '/var/run/nxlog/devlog'
end

nxlog_source 'syslog' do
  input_module 'im_uds'
  uds '/var/run/nxlog/devlog'
  exec 'parse_syslog_bsd();'
  flow_control false
  destination destinations
end
