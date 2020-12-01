# InSpec test for recipe chef-linux-base-recipe::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

%w(bash curl wget unzip mlocate).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

# Looking at the differences in VIM that is installed
if os.family == 'debian'
  describe package('vim') do
    it { should be_installed }
  end
end

if os.family == 'redhat'
  describe package('vim-common') do
    it { should be_installed }
  end
end
