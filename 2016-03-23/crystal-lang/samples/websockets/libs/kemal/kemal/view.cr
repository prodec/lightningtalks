# Template for 403 Forbidden
def render_403(context)
  template = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <style type="text/css">
        body { text-align:center;font-family:helvetica,arial;font-size:22px;
          color:#888;margin:20px}
        #c {margin:0 auto;width:500px;text-align:left}
        </style>
      </head>
      <body>
        <h2>Forbidden</h2>
        <h3>Kemal doesn't allow you to see this page.</h3>
        <img src="/__kemal__/404.png">
      </body>
      </html>
  HTML
  context.response.content_type = "text/html"
  context.response.status_code = 403
  context.response.print template
  context
end

# Template for 404 Not Found
def render_404(context)
  template = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <style type="text/css">
        body { text-align:center;font-family:helvetica,arial;font-size:22px;
          color:#888;margin:20px}
        #c {margin:0 auto;width:500px;text-align:left}
        </style>
      </head>
      <body>
        <h2>Kemal doesn't know this way.</h2>
        <img src="/__kemal__/404.png">
      </body>
      </html>
  HTML
  context.response.content_type = "text/html"
  context.response.status_code = 404
  context.response.print template
  context
end

# Template for 500 Internal Server Error
def render_500(context, backtrace, verbosity)
  message = if verbosity
              "<pre>#{backtrace}</pre>"
            else
              "<p>Something wrong with the server :(</p>"
            end

  template = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <style type="text/css">
        body { text-align:center;font-family:helvetica,arial;font-size:22px;
          color:#888;margin:20px}
        #c {margin:0 auto;width:500px;text-align:left}
        pre {text-align:left;font-size:14px;color:#fff;background-color:#222;
          font-family:Operator,"Source Code Pro",Menlo,Monaco,Inconsolata,monospace;
          line-height:1.5;padding:10px;border-radius:2px;overflow:scroll}
        </style>
      </head>
      <body>
        <h2>Kemal has encountered an error. (500)</h2>
        #{message}
      </body>
      </html>
  HTML
  context.response.content_type = "text/html"
  context.response.status_code = 500
  context.response.print template
  context
end

# Template for 415 Unsupported media type
def render_415(context, message)
  template = <<-HTML
          <!DOCTYPE html>
          <html>
          <head>
            <style type="text/css">
            body { text-align:center;font-family:helvetica,arial;font-size:22px;
              color:#888;margin:20px}
            #c {margin:0 auto;width:500px;text-align:left}
            </style>
          </head>
          <body>
            <h2>Unsupported media type</h2>
            <h3>#{message}</h3>
            <img src="/__kemal__/404.png">
          </body>
          </html>
      HTML
  context.response.content_type = "text/html"
  context.response.status_code = 415
  context.response.print template
  context
end

# Template for 400 Bad request
def render_400(context, message)
  template = <<-HTML
          <!DOCTYPE html>
          <html>
          <head>
            <style type="text/css">
            body { text-align:center;font-family:helvetica,arial;font-size:22px;
              color:#888;margin:20px}
            #c {margin:0 auto;width:500px;text-align:left}
            </style>
          </head>
          <body>
            <h2>Bad request</h2>
            <h3>#{message}</h3>
            <img src="/__kemal__/404.png">
          </body>
          </html>
      HTML
  context.response.content_type = "text/html"
  context.response.status_code = 400
  context.response.print template
  context
end
