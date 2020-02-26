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

# creates the same resources as test_default_resources, but as node attributes

node.override['nxlog'] = JSON.parse(<<EOT)
{
  "destinations": {
    "test_om_file_1": {
      "file": "/var/log/mark.log",
      "default": true
    },
    "test_om_file_2": {
      "file": "/var/log/mark2.log",
      "default": true
    },
    "test_om_file_3": {
      "file": "/var/log/mark3.log"
    }
  },
  "sources": {
    "test_im_mark_1": {
      "input_module": "im_mark",
      "mark_interval": 1
    },
    "test_im_mark_2": {
      "input_module": "im_mark",
      "mark_interval": 1,
      "destination": "foo"
    },
    "test_im_mark_3": {
      "input_module": "im_mark",
      "mark_interval": 1,
      "destination": ["foo", "bar"]
    },
    "test_im_mark_4": {
      "input_module": "im_mark",
      "mark_interval": 1,
      "destination": ["foo", "bar", "defaults"]
    }
  }
}
EOT

include_recipe 'nxlog::default'
