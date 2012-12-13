require 'buildr/git_auto_version'

desc 'FGIS: Fire Ground Information System'
define 'fgis' do
  project.group = 'org.realityforge.fgis'

  compile.options.source = '1.7'
  compile.options.target = '1.7'
  compile.options.lint = 'all'

  bootstrap_path = add_bootstrap_media(project)
  leaflet_path = add_leaflet_media(project)
  sass_path = define_process_sass_dir(project)
  coffee_script_path = define_coffee_script_dir(project)
  jquery_path = define_jquery_dir(project)

  assets = [bootstrap_path, leaflet_path, sass_path, coffee_script_path, jquery_path]

  desc 'Build assets'
  task 'assets' do
    assets.each do |asset|
      file(asset).invoke
    end
  end

  project.resources do
    task('assets').invoke
  end

  package(:war).tap do |war|
    assets.each do |asset|
      war.include asset, :as => '.'
    end
  end

  iml.add_ejb_facet
  iml.add_jpa_facet
  iml.add_web_facet(:webroots => [_(:source, :main, :webapp)] + assets)

  ipr.add_exploded_war_artifact(project,
                                :build_on_make => true,
                                :enable_ejb => true,
                                :enable_jpa => true,
                                :dependencies => [project])
end
