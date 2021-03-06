module My

#-------------------------------------------      
# All Pdf forms/documents are generated here  
#-------------------------------------------
  module Docs

    require 'prawn'
    require 'prawn/table'
    require 'prawn/measurement_extensions'
    include ActionView::Helpers::NumberHelper

# Generate Client/Product/Summary Report
  def build_report( report, orders )
    case report.category
      when PRODUCT_REPORT
        pdf = build_product_report(report, orders)
      when CLIENT_REPORT
        pdf = build_client_report(report, orders)
      when SUMMARY_REPORT
        pdf = build_summary_report(report, orders)
      else   
        logger.error "*** Report error: Invalid category #{report.inspect}"
      end
  end

# Generate product report. Filter placements to include only product report was created for 
  def build_product_report (report, placements)  
    client_name = report.client.name rescue 'All'
    cn_report = (report.geo == GEO_CN) || report.client.cn?
    if cn_report
      fx = ''
      locale = :cn
    else
      fx = "Fx USD/EUR: #{USD_EUR_FX}" unless report.client && report.client.currency == :eur
      locale = :fr
    end

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [20.mm,8.mm,20.mm,15.mm])
    pdf.font "Helvetica"
    ref_code = report.product.present? ? report.product.ref_code : 'All products'
    pdf.text "#{ref_code}: #{report.category_str} Report: #{report.status_str} Placements - #{report.timeframe_str}", align: :center, size: 15, style: :bold

    pdf.text "#{report.daterange}, #{placements.count} orders; Client: #{client_name}; #{fx}", align: :center, size: 10, style: :bold
  
    pdf.move_down 5.mm
    pdf.font_size 9

    if cn_report
      rows =  [[ '#', 'Ref.Code', "Client", "Order#", "Ttl.Pcs", "Pending", "Shipped", "Ordered", "Order Status", "PO#" ]]
    else 
      rows =  [[ '#', 'Ref.Code', "Client", "Order#", "Ttl.Pcs", "Pending", "Shipped", "Ordered", "Order Status", "PO#", "Subtotal"]]
    end
    
    ttl_pcs = pending_pcs = shipped_pcs = num = 0; subtotal = ttl_amount = 0.0
    placements.each do |pl|
      o = pl.order
      num += 1
      subtotal = pl.price * pl.quantity
      if cn_report
        rows += [[num, pl.product.ref_code, o.client.code, o.id, pl.quantity, pl.pending, pl.shipped, o.created_at.to_date, pl.status_str, o.po_number ]] 
      else
        rows += [[num, pl.product.ref_code, o.client.code, o.id, pl.quantity, pl.pending, pl.shipped, o.created_at.to_date, pl.status_str, o.po_number, number_to_currency(subtotal,locale: o.client.locale) ]] 
      end

      ttl_pcs += pl.quantity
      pending_pcs += pl.pending
      shipped_pcs += pl.shipped
      ttl_amount += subtotal * o.client.fx_rate   # we convert all to euros
    end
    if cn_report
      rows += [['','','','',ttl_pcs,pending_pcs,shipped_pcs, '','','']]
    else
      rows += [['','','','',ttl_pcs,pending_pcs,shipped_pcs, '','','',  number_to_currency(ttl_amount, locale: locale)]]
    end

    pdf.table rows, cell_style: {inline_format: true} do |t|
        t.cells.border_width = 0
        t.column_widths = [8.mm, 18.mm, 20.mm, 15.mm, 15.mm, 15.mm, 15.mm, 22.mm, 20.mm, 20.mm, 20.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
        t.row(0).min_font_size = t.row(-1).min_font_size = 10
        t.position = 5.mm
        t.cells.padding = 3

        t.cells.style do |c|
          c.background_color = c.row.odd? ? 'EEEEEE' : 'FFFFFF'
        end
    end

    return pdf
  end # generate_product_report

# Generate Client Report
  def build_client_report( report, orders )
    client_name = report.client.name rescue 'All'
    cn_report = (report.geo == GEO_CN) || report.client.cn? rescue false
    if cn_report
      fx = ''
      locale = :cn
    else
      fx = "Fx USD/EUR: #{USD_EUR_FX}" unless report.client && report.client.currency == :eur
      locale = :fr
    end

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [20.mm,8.mm,20.mm,15.mm])
    pdf.font "Helvetica"
    pdf.text "#{report.detail_str} #{report.category_str} Report: #{report.status_str} Orders - #{report.timeframe_str}", align: :center, size: 15, style: :bold

    pdf.text "#{report.daterange} #{orders.count} orders; Client: #{client_name}; #{fx}", align: :center, size: 10, style: :bold
  
    pdf.move_down 5.mm
    pdf.font_size 9
    if cn_report
      rows =  [[ '#', "Client", "Order", "Items", "Pcs", "Shipped", "Ordered", "Status", "Invoice"]]
    else
      rows =  [[ '#', "Client", "Order", "Items", "Pcs", "Shipped", "Ordered", "Status", "Invoice", "Total"]]
    end
    
    ttl_products = ttl_amount = ttl_pcs = ttl_shipped = num = 0
    orders.all.each do |o|
      num += 1
      if cn_report
        rows += [["<b>#{num}</b>", o.client.code, o.id, o.products.count, o.total_pcs, o.shipped, o.created_at.to_date, o.status_str.to_s, o.inv_number ]]
      else
        rows += [["<b>#{num}</b>", o.client.code, o.id, o.products.count, o.total_pcs, o.shipped, o.created_at.to_date, o.status_str.to_s, o.inv_number, number_to_currency(o.total,locale: o.client.locale)]]
      end
      if report.detail == ITEMIZED_REPORT
         o.placements.each do |pl|
           price  = number_to_currency(pl.price, locale: o.client.locale)
           total  = number_to_currency(pl.price * pl.quantity, locale: o.client.locale)
           if cn_report
             rows += [['','', {content: "<b>#{pl.product.ref_code}</b>: #{pl.product.scale_str}  #{pl.product.colour_str} x #{pl.quantity} pcs Status: #{pl.status_str} Shipped: #{pl.shipped} pcs", colspan: 6, align: :left} ]] 
           else
             rows += [['', {content: "<b>#{pl.product.ref_code}</b>: #{pl.product.scale_str}  #{pl.product.colour_str} x #{pl.quantity} pcs @ #{price}; Subtotal: #{total}; Status: #{pl.status_str} Shipped: #{pl.shipped} pcs", colspan: 8, align: :left} ]] 
           end
         end
         rows += [[ {size:25}, {size:20}, {size:20} ]]
      end
      ttl_products += o.products.count
      ttl_pcs += o.total_pcs
      ttl_shipped += o.shipped
      ttl_amount += o.total * o.client.fx_rate   # we convert to euros for WRLD clients only
    end
    if cn_report
      rows += [['','','',ttl_products,ttl_pcs,ttl_shipped,'','','']]
    else
      rows += [['','','',ttl_products,ttl_pcs,ttl_shipped,'','','',  number_to_currency(ttl_amount, locale: locale)]]
    end

    pdf.table rows, cell_style: {inline_format: true} do |t|
        t.cells.border_width = 0
        t.column_widths = [10.mm, 22.mm, 16.mm, 16.mm, 16.mm, 16.mm, 27.mm, 22.mm, 22.mm, 22.mm ]
        t.header = true
        t.row(0).font_style = t.row(-1).font_style = :bold
        t.row(0).min_font_size = t.row(-1).min_font_size = 12
        t.position = 5.mm
        t.cells.padding = 3

        if report.detail == TOTALS_ONLY_REPORT
          t.cells.style do |c|
            c.background_color = c.row.odd? ? 'EEEEEE' : 'FFFFFF'
          end
        end
    end

    return pdf
  end  # build_client_report


  # Generate Summary Report (to be finished)
  def build_summary_report( report, placements )
    client_name = report.client.name rescue 'All'
    if report.client.cn?
      fx = ''
      locale = :cn
    else
      fx = "Fx USD/EUR: #{USD_EUR_FX}" unless report.client && report.client.currency == :eur
      locale = :fr
    end

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [20.mm,8.mm,20.mm,15.mm])
    pdf.font "Helvetica"
    pdf.text "#{report.detail_str} #{report.category_str} Report: #{report.status_str} Orders - #{report.timeframe_str}", align: :center, size: 15, style: :bold

    pdf.text "#{report.daterange} #{placements.count} placements; Client: #{client_name}; #{fx}", align: :center, size: 10, style: :bold

    pdf.move_down 5.mm
    pdf.font_size 9
    rows =  [[ '#', "Ref.Code", "Pcs", "Orders", "Active", "Shipped", "Total"]]

    return pdf
  end # build_summary_report

  def build_ppo_pdf( ppo )
    return unless ppo.present?
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
    rows += [['','','','', ppo.quantity, '' ]]

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
    client_contact = "<b>#{cl.name}</b> <br><br>#{cl.address}<br> #{cl.state_prov} #{cl.country_str} #{cl.zip_postal} <br>VAT: #{cl.vat} <br>Phone: #{cl.contact_phone}<br>Email: #{cl.contact_email}"  
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
      next if p.cancelled?
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
    pdf.text "Grand Total (Including Tax): #{number_to_currency(order.grand_total, locale: order.client.locale)}", style: :bold

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
      next if p.cancelled?
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
    pdf.text "Grand Total (Including Tax): #{number_to_currency(order.grand_total, locale: order.client.locale)}", style: :bold

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



