open TestFramework;
open Jose;

let {describe} =
  describeConfig
  |> withLifecycle(testLifecycle =>
       testLifecycle |> beforeAll(() => Nocrypto_entropy_unix.initialize())
     )
  |> build;

describe("JWT", ({test}) => {
  let jwk = Jwk.Pub.of_pub_pem(Fixtures.rsa_test_pub) |> CCResult.get_exn;

  test("Can validate a JWT", ({expect}) => {
    let jwt_result =
      Jwt.of_string(Fixtures.external_jwt_string)
      |> CCResult.get_exn
      |> Jwt.validate(
           ~jwks=
             Jwks.{
               keys: [
                 {...jwk, kid: "0IRFN_RUHUQcXcdp_7PLBxoG_9b6bHrvGH0p8qRotik"},
               ],
             },
         );

    expect.result(jwt_result).toBeOk();
  });

  test("Can create a JWT", ({expect}) => {
    let header = Header.make_header(Fixtures.public_jwk);
    let payload =
      Jwt.empty_payload |> Jwt.add_claim("sub", `String("tester"));
    let jwt =
      Jwt.sign(
        ~header,
        ~payload,
        Fixtures.private_jwk |> Jwk.Priv.to_priv |> CCResult.get_exn,
      );

    expect.string(
      jwt |> CCResult.flat_map(Jwt.to_string) |> CCResult.get_exn,
    ).
      toEqual(
      Fixtures.external_jwt_string,
    );
  });

  test("Can validate my own JWT", ({expect}) => {
    let header = Header.make_header(Fixtures.public_jwk);
    let payload =
      Jwt.empty_payload |> Jwt.add_claim("sub", `String("tester"));
    let jwt =
      Jwt.sign(
        ~header,
        ~payload,
        Fixtures.private_jwk |> Jwk.Priv.to_priv |> CCResult.get_exn,
      )
      |> CCResult.get_exn;

    expect.result(
      Jwt.validate(~jwks=Jwks.{keys: [Fixtures.public_jwk]}, jwt),
    ).
      toBeOk();
  });
});