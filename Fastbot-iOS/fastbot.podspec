#MIT License
#
#** ** **
#The fastbot SDK is licensed under the MIT License:
#
#Copyright (c) 2021 Bytedance Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'fastbot'
  s.version          = '0.2.0'
  s.summary          = 'Fastbot-iOS'
  s.homepage         = 'https://github.com/bytedance/Fastbot-iOS'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'fastbot' => 'smart-qa@bytedance.com' }
  s.source           = { :git => '', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.13'
  
  s.xcconfig = { 'SYSTEM_FRAMEWORK_SEARCH_PATHS' => '"$(PLATFORM_DIR)/Developer/Library/PrivateFrameworks" "$(PLATFORM_DIR)/Developer/Library/Frameworks"', 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  
  s.frameworks = 'XCTest', 'XCTAutomationSupport'
  s.libraries = ['xml2.2']
  

  s.subspec 'fastbot' do |ss|
    ss.vendored_frameworks = ["fastbot/fastbot_native.framework","fastbot/fastbot_cv.framework","fastbot/FastbotLib.framework"]
    ss.source_files = "fastbot/Headers/*.{h}"
    ss.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) FASTBOT_NATIVE=1' }
  end


  s.subspec 'fastbot-stub' do |ss|
    ss.vendored_frameworks = ['XCTest', 'XCTAutomationSupport']
    ss.source_files = "fastbot-stub/*.{h,m,mm}"
  end
end
