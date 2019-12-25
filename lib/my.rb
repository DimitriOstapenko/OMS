module My

#-------------------------------------------      
# All Pdf forms/documents are generated here  
#-------------------------------------------
  module Forms

    require 'prawn'
    require 'prawn/table'
    require 'prawn/measurement_extensions'
    include ActionView::Helpers::NumberHelper

# Generate Totals Only report  
  def build_totals_report( report, orders )
    sdate = report.sdate.strftime("%d %b %Y")
    edate = report.edate.strftime("%d %b %Y")
    date_range = report.daterange
    client_name = report.client.name rescue 'All'
    if report.rtype == SALES_REPORT 
      ref_doc_name = 'Invoice'
    else
      ref_doc_name = 'P.O.'
    end

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,20.mm,20.mm])
    pdf.font "Courier"
    pdf.text "#{report.detail_str} #{report.rtype_str} #{report.timeframe_str} Report", align: :center, size: 12, style: :bold
    pdf.text "#{report.daterange}. #{orders.count} orders; Client: #{client_name}; USD/CAD: #{get_usd_euro_fx}", align: :center, size: 10, style: :bold
  
    pdf.move_down 5.mm
    pdf.font_size 8
    rows =  [[ "Client", "Order", "Products", "Date", "Status", ref_doc_name, "Total"]]
    
    ttl_products = ttl_amount = 0
    orders.all.each do |o|
      ref_doc = o.inv_number if report.rtype == SALES_REPORT
      ref_doc ||= o.po_number
      rows += [[o.client_code, o.id, o.products.count, o.created_at.to_date, o.status_str.to_s, ref_doc, number_to_currency(o.total,locale: o.client.locale)]]
      ttl_products += o.products.count
      ttl_amount += o.total * o.client.fx_rate   # we convert all to euros
    end
    rows += [['','',ttl_products,'','','',  number_to_currency(ttl_amount, locale: :fr)]]

    pdf.table rows do |t|
        t.cells.border_width = 0
        t.column_widths = [30.mm, 20.mm, 20.mm, 30.mm, 20.mm, 30.mm, 30.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
        t.position = 5.mm
        t.cells.padding = 3
        t.cells.style do |c|
           c.background_color = c.row.odd? ? 'EEEEEE' : 'FFFFFF'
        end
    end

    return pdf
  end

  def build_po(order)
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,20.mm,20.mm])
    pdf.font "Helvetica"
    pdf.font_size 9

    pdf.text_box APD_CONTACT, :at => [0.mm,240.mm],
         :width => 90.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true
    
    cl = order.client
    client_contact = "<b>#{cl.name}</b> <br><br>#{cl.address} #{cl.state_prov} #{cl.country_str} #{cl.zip_postal} <br>VAT: #{cl.vat} <br>Phone: #{cl.contact_phone}<br>Email: #{cl.contact_email}"  
    pdf.text_box client_contact, :at => [110.mm,240.mm],
         :width => 90.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

    pdf.move_down 50.mm
    pdf.text "Order # #{order.id} Date: #{order.cre_date}  #{order.placements.count} products", align: :center, size: 10, style: :bold

    pdf.move_down 8.mm

    rows =  [[ "#", "Product", "Scale", "Color", "Description", "Price", "Qty", "Total"]]

    num = ttl_items = ttl_amount = 0
    order.placements.each do |p|
      num +=1
      ttl_items += p.quantity
      ttl_amount += p.ptotal
      rows += [[num, p.product.ref_code, p.product.scale_str, p.product.colour_str, p.product.description, number_to_currency(p.price, locale: order.client.locale), p.quantity, number_to_currency(p.ptotal, locale: order.client.locale)]]
    end
    rows += [['','','','','','', ttl_items,  number_to_currency(ttl_amount, locale: order.client.locale)]]

    pdf.table rows do |t|
        t.cells.border_width = 0
        t.column_widths = [15.mm, 30.mm, 20.mm, 20.mm, 40.mm, 20.mm, 15.mm, 20.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
#        t.position = 5.mm
        t.cells.padding = 3
        t.cells.style do |c|
           c.background_color = c.row.odd? ? 'FFFFFF' : 'EEEEEE'
        end
    end

    return pdf
  end # build_po

  def build_invoice(order)
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,20.mm,20.mm])
    pdf.font "Helvetica"
    pdf.font_size 9

    cl = order.client
    inv_to = "<b>Invoice to: <br><br>#{cl.name}</b> <br><br>#{cl.address} #{cl.state_prov} #{cl.country_str} #{cl.zip_postal} <br>VAT: #{cl.vat}"
    
    deliver_to = "<b>Deliver to:<br><br>#{cl.name}</b> <br><br>#{cl.address} #{cl.state_prov} #{cl.country_str} #{cl.zip_postal} <br>Phone: #{cl.contact_phone}<br>Email: #{cl.contact_email}"  

    pdf.text_box APD_CONTACT, :at => [0.mm,245.mm],
         :width => 180.mm,
         :height => 25.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 12,
         :inline_format => true,
         :align => :center

    pdf.text_box inv_to, :at => [0.mm,215.mm],
         :width => 90.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true
    
    pdf.text_box deliver_to, :at => [110.mm,215.mm],
         :width => 90.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

    pdf.move_down 80.mm
    pdf.text "Invoice # #{order.inv_number} Date: #{Date.today}  #{order.placements.count} products", align: :center, size: 12, style: :bold

    pdf.move_down 8.mm
    pdf.text "<b>Transport:</b> #{order.delivery_by_str}", inline_format: true
    pdf.text "<b>Payment Terms:</b> #{order.terms_str}", inline_format: true
    pdf.move_down 5.mm

    rows =  [[ "#", "Product", "Scale", "Color", "Description", "Price", "Qty", "Total"]]

    num = ttl_items = ttl_amount = 0
    order.placements.each do |p|
      num +=1
      ttl_items += p.quantity
      ttl_amount += p.ptotal
      rows += [[num, p.product.ref_code, p.product.scale_str, p.product.colour_str, p.product.description, number_to_currency(p.price, locale: order.client.locale), p.quantity, number_to_currency(p.ptotal, locale: order.client.locale)]]
    end
    rows += [['','','','','','', ttl_items,  number_to_currency(ttl_amount, locale: order.client.locale)]]

    pdf.table rows do |t|
        t.cells.border_width = 0
        t.column_widths = [15.mm, 30.mm, 20.mm, 20.mm, 40.mm, 20.mm, 15.mm, 20.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
#        t.position = 0.mm
        t.cells.padding = 3
        t.cells.style do |c|
           c.background_color = c.row.odd? ? 'FFFFFF' : 'EEEEEE'
        end
    end
    
    pdf.move_down 20.mm
    pdf.text "Please check the integrity of the product.", style: :italic
    pdf.text "We only accept complaints about defects within 72 hours after the receipt of goods", style: :italic

    pdf.move_down 20.mm
    pdf.text "<b>Beneficiary Name</b> : ASIA PREMIER DEVELOPMENT LIMITED", inline_format: true
    pdf.text "<b>Beneficiary Address:</b> Room 1616, 16/F., Lippo Centre, Tower 2, 89 Queensway, Admiralty, Hong Kong", inline_format: true
    pdf.text "<b>Bank Name:</b> Standard Chartered Bank (Hong Kong) Limited", inline_format: true
    pdf.text "<b>Bank Address:</b> 13/F., Standard Chartered Bank Building, 4-4A Des Voeux Road Central, Hong Kong", inline_format: true
    pdf.text "<b>Account:</b>  447-0-817019-9", inline_format: true
    pdf.text "<b>SWIFT:</b> SCBLHKHHXXX", inline_format: true

    if order.notes.present?
      pdf.move_down 20.mm
      pdf.text "Notes:", style: :bold
      pdf.text order.notes
    end

    return pdf
  end

  end # Forms module
end # My



