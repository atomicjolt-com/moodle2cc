module Moodle2AA
  class Moodle2Converter::BookConverter
    include Moodle2Converter::ConverterHelper

    def convert(moodle_book)
      canvas_module = convert_moodle_book(moodle_book)
      moodle_book.chapters.each do |chapter|
        canvas_module.module_items << convert_moodle_chapter(moodle_book, chapter)
      end
      canvas_module
    end

    def convert_to_pages(moodle_book)
      pages = moodle_book.chapters.map do |moodle_chapter|
        page = create_page(moodle_chapter.title)
        page.identifier = generate_unique_identifier_for_activity(moodle_chapter)
        page.body = moodle_chapter.content
        page.workflow_state = workflow_state(moodle_book.visible)
        page
      end

      if moodle_book.intro && moodle_book.intro.length > 0
        page = create_page(moodle_book.name)
        page.identifier = generate_unique_identifier_for_activity(moodle_book)
        page.body = moodle_book.intro
        if pages.any?{|p| page.title == p.title}
          page.title = "#{truncate_text(page.title, MAX_TITLE_LENGTH - 20)} (Introduction)"
        end
        page.workflow_state = workflow_state(moodle_book.visible)
        pages.unshift(page)
      end

      pages
    end

    def convert_to_module_items(moodle_book)
      module_items = []
      module_items << create_title(moodle_book)
      module_items << create_introduction(moodle_book) if moodle_book.intro && moodle_book.intro.length > 0
      module_items += moodle_book.chapters.map { |chapter| create_chapter(chapter) }
      module_items
    end

    private

    def create_title(moodle_book)
      module_item = create_module_item_with_defaults()
      module_item.content_type = Moodle2AA::CanvasCC::Models::ModuleItem::CONTENT_TYPE_CONTEXT_MODULE_SUB_HEADER
      module_item.title = truncate_text(moodle_book.name)
      module_item.indent = "0"
      module_item.identifier = generate_unique_identifier()
      module_item.workflow_state = workflow_state(moodle_book.visible)

      module_item
    end

    def create_introduction(moodle_book)
      module_item = create_module_item_with_defaults()
      module_item.title = 'Introduction'
      module_item.indent = '1'
      module_item.identifierref = get_unique_identifier_for_activity(moodle_book)
      module_item.workflow_state = workflow_state(moodle_book.visible)

      module_item
    end

    def create_chapter(moodle_chapter)
      module_item = create_module_item_with_defaults()
      module_item.title = truncate_text(moodle_chapter.title)
      module_item.indent = moodle_chapter.subchapter ? "2" : "1"
      module_item.identifierref = get_unique_identifier_for_activity(moodle_chapter)
      module_item.workflow_state = CanvasCC::Models::WorkflowState::UNPUBLISHED if moodle_chapter.hidden

      module_item
    end

    def create_module_item_with_defaults
      module_item = CanvasCC::Models::ModuleItem.new
      module_item.identifier = generate_unique_identifier()
      module_item.content_type = CanvasCC::Models::ModuleItem::CONTENT_TYPE_WIKI_PAGE
      module_item.workflow_state = CanvasCC::Models::WorkflowState::ACTIVE
      module_item
    end

    def create_page(title)
      page = CanvasCC::Models::Page.new
      page.type = CanvasCC::Models::Resource::WEB_CONTENT_TYPE
      page.href = generate_unique_resource_path(CanvasCC::Models::Page::BOOK_PATH, title)
      page.title = truncate_text(title)
      page.workflow_state = CanvasCC::Models::WorkflowState::ACTIVE
      page.editing_roles = CanvasCC::Models::Page::EDITING_ROLE_TEACHER
      page
    end
  end
end