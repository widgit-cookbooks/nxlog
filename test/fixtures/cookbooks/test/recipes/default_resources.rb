#
# Cookbook Name:: nxlog
# Recipe:: default
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

nxlog_destination 'test_om_file_1' do
  file '/var/log/mark.log'
  default true
end

nxlog_destination 'test_om_file_2' do
  file '/var/log/mark2.log'
  default true
end

nxlog_destination 'test_om_file_3' do
  file '/var/log/mark3.log'
end

nxlog_source 'test_im_mark_1' do
  input_module 'im_mark'
  mark_interval 1
end

nxlog_source 'test_im_mark_2' do
  input_module 'im_mark'
  mark_interval 1
  destination 'foo'
end

nxlog_source 'test_im_mark_3' do
  input_module 'im_mark'
  mark_interval 1
  destination %w(foo bar)
end

nxlog_source 'test_im_mark_4' do
  input_module 'im_mark'
  mark_interval 1
  destination %w(foo bar defaults)
end
