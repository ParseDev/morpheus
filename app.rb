require "sinatra"
require "stringio"
require "json"

post "/execute" do
  request_payload = JSON.parse(request.body.read)
  code = request_payload["code"]

  # Redirect stdout to a string buffer
  stdout_buffer = StringIO.new
  original_stdout = $stdout
  $stdout = stdout_buffer

  result = nil
  error = nil
  captured_output = ""

  begin
    # Execute the code
    result = eval(code) # Note: Be cautious when executing arbitrary code like this
  rescue Exception => e
    # Capture any error and store it
    error = e.to_s
  ensure
    # Restore the original stdout and retrieve the captured output
    $stdout = original_stdout
    captured_output = stdout_buffer.string
  end

  # Return the response in JSON format
  content_type :json
  if error.nil?
    { result: result, output: captured_output }.to_json
  else
    { error: error, output: captured_output }.to_json
  end
end
