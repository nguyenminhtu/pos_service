module ProductServices
  class ImportFromFile
    def initialize args = {}
      @file = args[:file]
    end

    def perform
      unless [".xls", ".xlsx"].include? File.extname(file.original_filename)
        return {
          success: false, message: I18n.t("import_from_file.extension_error")
        }
      end
      ActiveRecord::Base.transaction do
        spreadsheet = open_spreadsheet
        header = spreadsheet.row 1
        (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          code = row["Mã hàng"]
          name = row["Tên hàng hoá"]
          sale_price = row["Giá bán"]
          initial_cost = row["Giá vốn"]
          stock_count = row["Tồn kho"]

          category = Category.find_by! name: row["Nhóm hàng"]
          properties = {
            code: code,
            sale_price: sale_price,
            initial_cost: initial_cost,
            stock_count: stock_count,
            category_id: category.id
          }
          if update_stock_count
            properties.merge! stock_count: row["Tồn kho"]
            # TODO: Lap phieu kiem kho
          end
          product = Product.find_by code: code
          if product
            product.update! properties
          else
            Product.create! properties
          end
        end
      end
      {success: true}
    rescue
      {
        success: false,
        message: I18n.t("products.import_failed")
      }
    end

    private

    attr_reader :file

    def open_spreadsheet
      case File.extname(file.original_filename)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise Exception
      end
    end
  end
end
