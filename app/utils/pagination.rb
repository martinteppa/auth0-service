class Pagination
  def self.paginate(entity_name, page, per_page, filters=nil)
    items = self.apply_filters(entity_name.constantize, filters)
                .page(page)
                .per(per_page)

    {
      message: "#{entity_name} retrieved successfully",
      result: items,
      current_page: items.current_page,
      total_pages: items.total_pages,
      total_count: items.total_count
    }
  end

  private

  def self.apply_filters(entity, filters)
    return entity if filters == nil
    filters = filters.dup

    if filters.key?(:not)
      entity = entity.where.not(filters[:not])
      filters.delete(:not)
    end

    entity = entity.where(filters) unless filters.empty?

    entity
  end
end