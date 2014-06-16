Pod::Spec.new do |s|
    s.name  = 'FastPdfKit'
    s.version = '4.5.8'
    s.platform = :ios, '6.0'
    s.homepage = 'http://www.fastpdfkit.com'
    s.authors = 'MobFarm'
    s.summary = 'PDF library for iOS'
    s.license = {:type => 'CCPL', :file => 'LICENSE.txt'}
    s.source = {:git => 'git@10.10.1.4:ios/fastpdfkit.git', :tag => s.version.to_s}
    s.requires_arc = true
    s.default_subspec = 'Reader'

    s.subspec 'Reader' do |r|
        r.source_files = 'Reader/**/*.{h,m}'
        r.resources = 'Reader/**/*.xib', 'Reader/FPKReader.xcassets'
        r.exclude_files = 'Reader/ThumbnailSlider/*.{h,m}'
        r.dependency 'FastPdfKit/Core'
    end
    
    s.subspec 'Core' do |c|
        c.source_files = 'Core/**/*.{h,m}'
        c.vendored_libraries = 'Core/libFastPdfKit.a'
    end
    
    s.subspec 'Extensions' do |e|
        e.source_files = 'Extensions/**/*.{h,m}'
        e.dependency 'FastPdfKit/Reader'
    end
end