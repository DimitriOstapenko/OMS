module My

#-------------------------------------------      
# All Pdf forms/documents are generated here  
#-------------------------------------------
  module Docs

    require 'prawn'
    require 'prawn/table'
    require 'prawn/measurement_extensions'
    include ActionView::Helpers::NumberHelper

# Generate Client/Product Report
  def build_report( report, orders )
    client_name = report.client.name rescue 'All'
    fx = "Fx USD/EUR: #{get_usd_euro_fx}"unless report.client && report.client.currency == :eur

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,20.mm,20.mm])
    pdf.font "Helvetica"
    pdf.text "#{report.detail_str} #{report.category_str} Report: #{report.status_str} Orders - #{report.timeframe_str}", align: :center, size: 15, style: :bold

    cat = (report.category == PRODUCT_REPORT) ? "Product: #{report.product.ref_code}" : "Client: #{client_name}"
    pdf.text "#{report.daterange} #{orders.count} orders; #{cat}; #{fx}", align: :center, size: 10, style: :bold
  
    pdf.move_down 5.mm
    pdf.font_size 9
    client_hdr = (report.category == PRODUCT_REPORT) ? 'Client' : '#'
    rows =  [[ client_hdr, "Order", "Items", "Pcs", "Date", "Status", "Invoice", "Total"]]
    
    ttl_products = ttl_amount = ttl_items = num = 0
    orders.all.each do |o|
      ref_doc = o.inv_number 
      num += 1
      col_1 = (report.category == PRODUCT_REPORT) ? o.client.name : num
      rows += [["<b>#{col_1}</b>", o.id, o.products.count, o.total_pcs, o.created_at.to_date, o.status_str.to_s, ref_doc, number_to_currency(o.total,locale: o.client.locale)]]
      if report.detail == ITEMIZED_REPORT
         o.placements.each do |pl|
           price  = number_to_currency(pl.price, locale: o.client.locale)
           total  = number_to_currency(pl.price * pl.quantity, locale: o.client.locale)
           rows += [['','', {content: "<b>#{pl.product.ref_code}</b>: #{pl.product.scale_str}  #{pl.product.colour_str} x #{pl.quantity} pcs @ #{price}; Subtotal: #{total}; Status: #{pl.status_str}", colspan: 6, align: :left} ]] 
         end
         rows += [[ {size: 25}]]
         rows += [[ {size: 25}]]
         rows += [[ {size: 25}]]
      end
      ttl_products += o.products.count
      ttl_items += o.total_pcs
      ttl_amount += o.total * o.client.fx_rate   # we convert all to euros
    end
    rows += [['Totals: ','',ttl_products,ttl_items,'','','',  number_to_currency(ttl_amount, locale: :fr)]]

    pdf.table rows, cell_style: {inline_format: true} do |t|
        t.cells.border_width = 0
        t.column_widths = [30.mm, 12.mm, 12.mm, 20.mm, 30.mm, 20.mm, 30.mm, 30.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
        t.row(0).min_font_size = t.row(-1).min_font_size = 10
        t.position = 5.mm
        t.cells.padding = 3

        if report.detail == TOTALS_ONLY_REPORT
          t.cells.style do |c|
            c.background_color = c.row.odd? ? 'EEEEEE' : 'FFFFFF'
          end
        end
    end

    return pdf
  end

  def build_ppo_pdf( ppo )
    product = ppo.product
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,20.mm,20.mm])
    pdf.font "Helvetica"
    pdf.font_size 9
 
    pdf.text_box APD_CONTACT, :at => [0.mm,240.mm],
         :width => 90.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true
    
    pdf.move_down 50.mm
    pdf.text "Production Purchase Order # #{ppo.name} ", align: :center, size: 12, style: :bold

    pdf.move_down 10.mm
    pdf.text "Item: #{product.ref_code}: #{product.description}", align: :left, size: 10, style: :bold
    pdf.text "PPO Date: #{ppo.date}", align: :left, size: 10, style: :bold
    pdf.move_down 8.mm

    rows =  [[ '#', 'Order#', 'Client', 'Ordered', 'Quantity', 'Status' ]]

    num = 0
#    product.active_order_placements.each do |pl|
    ppo.placements.each do |pl|
      num +=1
      rows += [[num, pl.order.id, pl.order.client_name, pl.order.cre_date, pl.quantity, pl.status_str ]] 
    end
    rows += [['','','','', ppo.pcs, '' ]]

    pdf.table rows do |t|
        t.cells.border_width = 0
        t.column_widths = [20.mm, 20.mm, 70.mm, 25.mm, 20.mm, 30.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
        t.cells.padding = 3
        t.cells.style do |c|
           c.background_color = c.row.odd? ? 'FFFFFF' : 'EEEEEE'
        end
    end
    
    return pdf
  end

# Generate PO  
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
    pdf.text "Purchase Order # #{order.po_number} Date: #{order.cre_date} ", align: :center, size: 12, style: :bold

    pdf.move_down 8.mm

    rows =  [[ "#", "Product", "Scale", "Color", "Description", "Price", "Qty", "Total"]]

    num = 0
    order.placements.each do |p|
      num +=1
      rows += [[num, p.product.ref_code, p.product.scale_str, p.product.colour_str, p.product.description, number_to_currency(p.price, locale: order.client.locale), p.quantity, number_to_currency(p.ptotal, locale: order.client.locale)]]
    end
    rows += [['','','','','','', order.total_pcs,  number_to_currency(order.total_price, locale: order.client.locale)]]

    pdf.table rows do |t|
        t.cells.border_width = 0
        t.column_widths = [15.mm, 30.mm, 20.mm, 20.mm, 40.mm, 20.mm, 15.mm, 20.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
        t.cells.padding = 3
        t.cells.style do |c|
           c.background_color = c.row.odd? ? 'FFFFFF' : 'EEEEEE'
        end
    end
   
    pdf.move_down 10.mm
    pdf.text "Payment Terms: #{order.terms_str}"
    pdf.text "Pyment Method: #{order.pmt_method_str}"

    pdf.text "Shipping & Handling: #{number_to_currency(order.shipping, locale: order.client.locale )}" if order.shipping.positive?
    pdf.text "Discount: #{number_to_currency(order.discount, locale: order.client.locale )}" if order.discount.positive?
    pdf.text "Sales Tax (#{order.client.tax_pc}%): #{number_to_currency(order.tax, locale: order.client.locale)}" if order.tax.positive?
    pdf.text "Grand Total (Including Tax): #{number_to_currency(order.total, locale: order.client.locale)}", style: :bold

    return pdf
  end # build_po

# Generate Invoice  
  def build_invoice(order)
    account = (order.currency == :usd)? USD_ACCOUNT : EU_ACCOUNT 
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
    
    pdf.move_down 30.mm
    pdf.text "Invoice # #{order.inv_number}", align: :center, size: 16, style: :bold

    pdf.text_box inv_to, :at => [0.mm,205.mm],
         :width => 90.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true
    
    pdf.text_box deliver_to, :at => [110.mm,205.mm],
         :width => 90.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

    pdf.move_down 50.mm
    pdf.text "<b>Order Date:</b> #{order.cre_date}", inline_format: true
    pdf.text "<b>Transport:</b> #{order.delivery_by}", inline_format: true
    pdf.text "<b>Payment Terms:</b> #{order.terms_str}", inline_format: true
    pdf.text "<b>Pyment Method:</b> #{order.pmt_method_str}", inline_format: true
    pdf.move_down 5.mm

    rows =  [[ "#", "Product", "Scale", "Color", "Description", "Price", "Qty", "Total"]]

    num = 0
    order.placements.each do |p|
      num +=1
      rows += [[num, p.product.ref_code, p.product.scale_str, p.product.colour_str, p.product.description, number_to_currency(p.price, locale: order.client.locale), p.quantity, number_to_currency(p.ptotal, locale: order.client.locale)]]
    end
    rows += [['','','','','','', order.total_pcs,  number_to_currency(order.total_price, locale: order.client.locale)]]

    pdf.table rows do |t|
        t.cells.border_width = 0
        t.column_widths = [15.mm, 30.mm, 20.mm, 20.mm, 40.mm, 20.mm, 15.mm, 20.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
        t.cells.padding = 3
        t.cells.style do |c|
           c.background_color = c.row.odd? ? 'FFFFFF' : 'EEEEEE'
        end
    end
    
    pdf.move_down 10.mm
    pdf.text "Order net weight: #{order.weight} Kg" if order.shipping.positive?
    pdf.text "Shipping & Handling: #{number_to_currency(order.shipping, locale: order.client.locale )}" if order.shipping.positive?
    pdf.text "Discount: #{number_to_currency(order.discount, locale: order.client.locale )}" if order.discount.positive?
    pdf.text "Sales Tax (#{order.client.tax_pc}%): #{number_to_currency(order.tax, locale: order.client.locale)}" if order.tax.positive?
    pdf.text "Grand Total (Including Tax): #{number_to_currency(order.total, locale: order.client.locale)}", style: :bold

    pdf.move_down 10.mm
    pdf.text "Please check the integrity of the product.", style: :italic
    pdf.text "We only accept complaints about defects within 72 hours after the receipt of goods", style: :italic

    pdf.move_down 10.mm
    pdf.text "<b>Beneficiary Name</b> : ASIA PREMIER DEVELOPMENT LIMITED", inline_format: true
    pdf.text "<b>Beneficiary Address:</b> Room 1616, 16/F., Lippo Centre, Tower 2, 89 Queensway, Admiralty, Hong Kong", inline_format: true
    pdf.text "<b>Bank Name:</b> Standard Chartered Bank (Hong Kong) Limited", inline_format: true
    pdf.text "<b>Bank Address:</b> 13/F., Standard Chartered Bank Building, 4-4A Des Voeux Road Central, Hong Kong", inline_format: true

    pdf.text "<b>Account:</b>  #{account}", inline_format: true
    pdf.text "<b>SWIFT:</b> SCBLHKHHXXX", inline_format: true

    if order.notes.present?
      pdf.move_down 10.mm
      pdf.text "Notes:", style: :bold
      pdf.text order.notes
    end

    return pdf
  end

  end # Docs module
end # My



