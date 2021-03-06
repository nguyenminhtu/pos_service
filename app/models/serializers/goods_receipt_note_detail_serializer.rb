module Serializers
  class GoodsReceiptNoteDetailSerializer < Serializers::BaseSerializer
    attrs :id, :goods_receipt_note_id, :product, :amount, :unit_price

    def product
      Serialiers::ProductSerializer.new object: object.product
    end
  end
end
