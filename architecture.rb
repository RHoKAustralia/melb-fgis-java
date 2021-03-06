Domgen.repository(:FGIS) do |repository|
  repository.enable_facet(:jpa)
  repository.enable_facet(:jackson)
  repository.enable_facet(:ejb)
  repository.enable_facet(:jaxrs)

  repository.jpa.provider = :eclipselink

  repository.data_module(:FGIS) do |data_module|

    data_module.struct(:ResourceDetailsDTO) do |s|
      s.text(:Type)
      s.text(:Name)
    end

    data_module.struct(:LocationUpdateDTO) do |s|
      s.datetime(:CollectedAt)
      s.real(:Coordinates, :collection_type => :sequence)
    end

    data_module.entity(:Resource) do |t|
      t.integer(:ID, :primary_key => true)
      t.text(:Type, :immutable => true)
      t.text(:Name, :immutable => true)
      t.point(:Location, :nullable => true) do |a|
        a.description("Location derived form last known location")
      end

      t.query(:FindByName)

      #t.sql.index([:Location], :index_type => :spatial)
    end

    data_module.entity(:ResourceTrack) do |t|
      t.integer(:ID, :primary_key => true)
      t.reference(:Resource, :immutable => true, :"inverse.traversable" => true)
      t.datetime(:CollectedAt, :immutable => true)
      t.point(:Location, :immutable => true)

      t.query(:FindAllByResourceSince) do |q|
        q.jpa.jpql = 'O.resource.id = :ResourceID AND O.collectedAt >= :StartAt ORDER BY O.collectedAt DESC'
        q.integer(:ResourceID)
        q.datetime(:StartAt)
      end

      t.query(:FindAllByResource) do |q|
        q.jpa.jpql = 'O.resource.id = :ResourceID'
        q.jpa.limit = true
        q.jpa.offset = true
        q.jpa.order_by = 'O.collectedAt DESC'
        q.integer(:ResourceID)
      end

      t.sql.index([:Location], :index_type => :gist)
    end
  end
end
