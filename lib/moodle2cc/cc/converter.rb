module Moodle2CC::CC
  class Converter
    include CCHelper

    def initialize(moodle_backup, destination_dir)
      @moodle_backup = moodle_backup
      @export_dir = Dir.mktmpdir
      @destination_dir = destination_dir
    end

    def imscc_file_name
      "#{file_slug(@moodle_backup.course.fullname)}.imscc"
    end

    def imscc_path
      @imscc_path ||= File.join(@destination_dir, imscc_file_name)
    end

    def imscc_tmp_path
      @imscc_tmp_path ||= File.join(@export_dir, imscc_file_name)
    end

    def convert
      File.open(File.join(@export_dir, MANIFEST), 'w') do |file|
        @document = Builder::XmlMarkup.new(:target => file, :indent => 2)
        @document.instruct!
        create_manifest
      end
      create_web_resources
      Zip::ZipFile.open(imscc_tmp_path, Zip::ZipFile::CREATE) do |zipfile|
        Dir["#{@export_dir}/**/*"].each do |file|
          zipfile.add(file.sub(@export_dir + '/', ''), file)
        end
      end
      FileUtils.mv imscc_tmp_path, imscc_path
      FileUtils.rm_r @export_dir
    end

    def create_manifest
      @document.manifest(
        "identifier" => create_key(@moodle_backup.course.id, "common_cartridge_"),
        "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1",
        "xmlns:lom" => "http://ltsc.ieee.org/xsd/imsccv1p1/LOM/resource",
        "xmlns:lomimscc" => "http://ltsc.ieee.org/xsd/imsccv1p1/LOM/manifest",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1 http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imscp_v1p2_v1p0.xsd http://ltsc.ieee.org/xsd/imsccv1p1/LOM/resource http://www.imsglobal.org/profile/cc/ccv1p1/LOM/ccv1p1_lomresource_v1p0.xsd http://ltsc.ieee.org/xsd/imsccv1p1/LOM/manifest http://www.imsglobal.org/profile/cc/ccv1p1/LOM/ccv1p1_lommanifest_v1p0.xsd"
      ) do |manifest_node|
        @manifest_node = manifest_node
        @manifest_node.metadata do |md|
          md.schema "IMS Common Cartridge"
          md.schemaversion "1.1.0"
          md.lomimscc :lom do |lom|
            lom.lomimscc :general do |general|
              general.lomimscc :title do |title|
                title.lomimscc :string, @moodle_backup.course.fullname
              end
            end
            lom.lomimscc :lifeCycle do |lifecycle|
              lifecycle.lomimscc :contribute do |contribute|
                contribute.lomimscc :date do |date|
                  date.lomimscc :dateTime, ims_date
                end
              end
            end
            lom.lomimscc :rights do |rights|
              rights.lomimscc :copyrightAndOtherRestrictions do |node|
                node.lomimscc :value, 'yes'
              end
              rights.lomimscc :description do |desc|
                desc.lomimscc :string, 'Private (Copyrighted) - http://en.wikipedia.org/wiki/Copyright'
              end
            end
          end
        end

        create_organizations
        create_resources
      end
    end

    def create_organizations
      course = Course.new(@moodle_backup.course)
      @manifest_node.organizations do |orgs|
        orgs.organization(
          :identifier => 'org_1',
          :structure => 'rooted-hierarchy'
        ) do |org|
          org.item(:identifier => "LearningModules") do |root_item|
            @moodle_backup.course.sections.each do |section|
              next unless section.visible
              root_item.item(:identifier => create_key(section.id, "section_")) do |item_node|
                item_node.title "#{course.format} #{section.number}"
                section.mods.each do |mod|
                  resource = Resource.get_from_mod(mod.instance)
                  resource.create_organization_item_node(item_node) if resource
                end
              end
            end
          end
        end
      end
    end

    def create_resources
      @manifest_node.resources do |resources_node|
        create_course_content(resources_node)

        @moodle_backup.course.mods.each do |mod|
          resource = Resource.get_from_mod(mod)
          if resource
            resource.create_resource_node(resources_node)
            resource.create_files(@export_dir)
          end
        end

        @moodle_backup.course.question_categories.each do |question_category|
          create_question_bank_resource(resources_node, question_category)
        end

        @moodle_backup.files.each do |file|
          href = File.join(WEB_RESOURCES_FOLDER, file)
          resources_node.resource(
            :type => WEBCONTENT,
            :identifier => create_key(href, 'resource_'),
            :href => href
          ) do |resource_node|
            resource_node.file(:href => href)
          end
        end
      end
    end

    def create_question_bank_resource(resources_node, question_category)
      question_bank = QuestionBank.new(question_category)
      question_bank.create_resource_node(resources_node)
      question_bank.create_files(@export_dir)
    end

    def create_course_content(resources_node)
      course = Course.new(@moodle_backup.course)
      course.create_resource_node(resources_node)
      course.create_files(@export_dir)
    end

    def create_web_resources
      web_resources_folder = File.join(@export_dir, WEB_RESOURCES_FOLDER)
      FileUtils.mkdir(web_resources_folder)
      @moodle_backup.copy_files_to(web_resources_folder)
    end

  end
end
