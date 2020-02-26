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
attribute :output_module, kind_of: String, default: 'om_file', required: true,
                          equal_to: %w(om_blocker om_dbi om_exec om_file om_http
                                       om_null om_ssl om_tcp om_udp om_ssl
                                       om_uds)
attribute :exec, kind_of: String
attribute :output_type, kind_of: String, equal_to: %w(LineBased Dgram Binary)
attribute :default, kind_of: [TrueClass, FalseClass]

# om_blocker

# om_dbi
attribute :driver, kind_of: String # required
attribute :sql, kind_of: String    # required
attribute :options, kind_of: Array

# om_exec
attribute :command, kind_of: String # required
attribute :args, kind_of: Array

# om_file
attribute :file, kind_of: String # required
attribute :create_dir, kind_of: [TrueClass, FalseClass]
attribute :truncate, kind_of: [TrueClass, FalseClass]
attribute :sync, kind_of: [TrueClass, FalseClass]

# om_http
attribute :url, kind_of: String # required
attribute :content_type, kind_of: String
attribute :https_cert_file, kind_of: String
attribute :https_cert_key_file, kind_of: String
attribute :https_key_pass, kind_of: String
attribute :https_ca_file, kind_of: String
attribute :https_ca_dir, kind_of: String
attribute :https_crl_file, kind_of: String
attribute :https_crl_dir, kind_of: String
attribute :https_allow_untrusted, kind_of: [TrueClass, FalseClass]

# om_null

# om_ssl, om_tcp, om_udp
attribute :host, kind_of: String # required
attribute :port, kind_of: Integer # required

# om_ssl
attribute :cert_file, kind_of: String
attribute :cert_key_file, kind_of: String
attribute :key_pass, kind_of: String
attribute :ca_file, kind_of: String
attribute :ca_dir, kind_of: String
attribute :crl_file, kind_of: String
attribute :crl_dir, kind_of: String
attribute :allow_untrusted, kind_of: [TrueClass, FalseClass]

# om_udp
attribute :sock_buf_size, kind_of: Integer

# om_uds
attribute :uds, kind_of: String, default: '/dev/log'
