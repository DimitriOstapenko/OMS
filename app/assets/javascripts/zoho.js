var $zoho=$zoho || {};$zoho.salesiq = $zoho.salesiq || 
{widgetcode:"95f01574a42eec0e1b7553a7a5d6bd00a8815a9c20ee952d9b109f0f52f0b4f0", values:{},ready:function(){}};
var d=document;s=d.createElement("script");s.type="text/javascript";s.id="zsiqscript";s.defer=true;
s.src="https://salesiq.zoho.eu/widget";t=d.getElementsByTagName("script")[0];t.parentNode.insertBefore(s,t);d.write("<div id='zsiqwidget'></div>");

$zoho.salesiq.ready=function()
{
        var email = '<%= current_user.email %>';
        $zoho.salesiq.visitor.email( email );
}
