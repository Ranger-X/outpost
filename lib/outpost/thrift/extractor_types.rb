#
# Autogenerated by Thrift Compiler (0.9.3)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#

require 'thrift'

class SearchKey
  include ::Thrift::Struct, ::Thrift::Struct_Union
  VALUE = 1
  KEYWORD = 2

  FIELDS = {
    VALUE => {:type => ::Thrift::Types::STRING, :name => 'value'},
    KEYWORD => {:type => ::Thrift::Types::STRING, :name => 'keyword'}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

class GeoLocation
  include ::Thrift::Struct, ::Thrift::Struct_Union
  COUNTRY = 1
  CITYID = 2

  FIELDS = {
    COUNTRY => {:type => ::Thrift::Types::STRING, :name => 'country'},
    CITYID => {:type => ::Thrift::Types::I32, :name => 'cityId'}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

class UserInfo
  include ::Thrift::Struct, ::Thrift::Struct_Union
  UATYPE = 1
  UANAME = 2
  OSFAMILY = 3
  OSNAME = 4

  FIELDS = {
    UATYPE => {:type => ::Thrift::Types::STRING, :name => 'uaType'},
    UANAME => {:type => ::Thrift::Types::STRING, :name => 'uaName'},
    OSFAMILY => {:type => ::Thrift::Types::STRING, :name => 'osFamily'},
    OSNAME => {:type => ::Thrift::Types::STRING, :name => 'osName'}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

class Profile
  include ::Thrift::Struct, ::Thrift::Struct_Union
  GEOLOCATION = 1
  USERINFO = 2

  FIELDS = {
    GEOLOCATION => {:type => ::Thrift::Types::STRUCT, :name => 'geoLocation', :class => ::GeoLocation},
    USERINFO => {:type => ::Thrift::Types::STRUCT, :name => 'userInfo', :class => ::UserInfo}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

class ProfileAndKeyword
  include ::Thrift::Struct, ::Thrift::Struct_Union
  PROFILE = 1
  KEYWORD = 2

  FIELDS = {
    PROFILE => {:type => ::Thrift::Types::STRUCT, :name => 'profile', :class => ::Profile},
    KEYWORD => {:type => ::Thrift::Types::STRING, :name => 'keyword'}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

