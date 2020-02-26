#
# Cookbook Name:: nxlog
# Resouce:: log_destination
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

actions :create, :delete
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true

# global parameters
attribute :input_module, kind_of: String, default: 'im_file', required: true,
                         equal_to: %w(im_exec im_file im_internal im_kernel
                                      im_mark im_mseventlog im_msvistalog
                                      im_null im_ssl im_tcp im_udp im_uds)
attribute :destination, kind_of: [String, Array], default: 'defaults'
attribute :input_type, kind_of: String
attribute :exec, kind_of: String
attribute :flow_control, kind_of: [TrueClass, FalseClass]

# not quite global, but somewhat common
attribute :save_pos, kind_of: [TrueClass, FalseClass]
attribute :read_from_last, kind_of: [TrueClass, FalseClass]

# im_dbi
# this is undocumented as far as I can tell, so I'm not sure what to do here

# im_exec
attribute :command, kind_of: String # required
attribute :args, kind_of: Array
attribute :restart, kind_of: [TrueClass, FalseClass]

# im_file
attribute :file, kind_of: String # required
attribute :recursive, kind_of: [TrueClass, FalseClass]
attribute :rename_check, kind_of: [TrueClass, FalseClass]
attribute :close_when_idle, kind_of: [TrueClass, FalseClass]
attribute :poll_interval, kind_of: Float
attribute :dir_check_interval, kind_of: Float
attribute :active_files, kind_of: Integer

# im_internal

# im_kernel

# im_mark
attribute :mark, kind_of: String
attribute :mark_interval, kind_of: Integer

# im_mseventlog
attribute :sources, kind_of: Array
attribute :utf8, kind_of: [TrueClass, FalseClass]

# im_msvistalog
attribute :query, kind_of: String
attribute :channel, kind_of: String
# defined above
# attribute :poll_interval, kind_of: Float

# im_null

# im_ssl, im_tcp, im_udp
attribute :host, kind_of: String, default: 'localhost'
attribute :port, kind_of: Integer # required

# im_ssl
attribute :cert_file, kind_of: String
attribute :cert_key_file, kind_of: String
attribute :key_pass, kind_of: String
attribute :ca_file, kind_of: String
attribute :ca_dir, kind_of: String
attribute :crl_file, kind_of: String
attribute :crl_dir, kind_of: String
attribute :allow_untrusted, kind_of: [TrueClass, FalseClass]

# im_udp
attribute :sock_buf_size, kind_of: Integer

# im_uds
attribute :uds, kind_of: String, default: '/dev/log'
