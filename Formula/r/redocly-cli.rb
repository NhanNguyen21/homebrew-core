class RedoclyCli < Formula
  desc "Your all-in-one OpenAPI utility"
  homepage "https://redocly.com/docs/cli"
  url "https://registry.npmjs.org/@redocly/cli/-/cli-1.31.0.tgz"
  sha256 "13928da058d1499baed1364e13dfc8b604c47a9dfb109395aa3aa0e15cc53d80"
  license "MIT"
  head "https://github.com/redocly/redocly-cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7c05aa35c873586a5acd90f51e677278483318d055215bbf7cb16ab171139f02"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "7c05aa35c873586a5acd90f51e677278483318d055215bbf7cb16ab171139f02"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7c05aa35c873586a5acd90f51e677278483318d055215bbf7cb16ab171139f02"
    sha256 cellar: :any_skip_relocation, sonoma:        "99dfbdf6b026d06d755a8586c68f1b502267bb4be7e089b4ddfcbdaf7519c7a2"
    sha256 cellar: :any_skip_relocation, ventura:       "99dfbdf6b026d06d755a8586c68f1b502267bb4be7e089b4ddfcbdaf7519c7a2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7c05aa35c873586a5acd90f51e677278483318d055215bbf7cb16ab171139f02"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/redocly --version")

    test_file = testpath/"openapi.yaml"
    test_file.write <<~YML
      openapi: '3.0.0'
      info:
        version: 1.0.0
        title: Swagger Petstore
        description: test
        license:
          name: MIT
          url: https://opensource.org/licenses/MIT
      servers: #ServerList
        - url: http://petstore.swagger.io:{Port}/v1
          variables:
            Port:
              enum:
                - '8443'
                - '443'
              default: '8443'
      security: [] # SecurityRequirementList
      tags: # TagList
        - name: pets
          description: Test description
        - name: store
          description: Access to Petstore orders
      paths:
        /pets:
          get:
            summary: List all pets
            operationId: list_pets
            tags:
              - pets
            parameters:
              - name: Accept-Language
                in: header
                description: 'The language you prefer for messages. Supported values are en-AU, en-CA, en-GB, en-US'
                example: en-US
                required: false
                schema:
                  type: string
                  default: en-AU
            responses:
              '200':
                description: An paged array of pets
                headers:
                  x-next:
                    description: A link to the next page of responses
                    schema:
                      type: string
                content:
                  application/json:
                    encoding:
                      historyMetadata:
                        contentType: application/json; charset=utf-8
                links:
                  address:
                    operationId: getUserAddress
                    parameters:
                      userId: $request.path.id
    YML

    assert_match "Woohoo! Your API description is valid. 🎉",
      shell_output("#{bin}/redocly lint --extends=minimal #{test_file} 2>&1")
  end
end
