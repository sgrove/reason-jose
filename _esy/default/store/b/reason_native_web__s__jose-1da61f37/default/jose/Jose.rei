/**
{1 JSON Web Key}
*/

module Jwk: {
  /**
  {1 Public keys}

  These keys are safe to show and should be used to verify signed content.
  */
  module Pub: {
    /**
    [t] describes a Public JSON Web Key
    */
    type t = {
      alg: option(string),
      kty: string,
      use: option(string),
      n: string,
      e: string,
      kid: string,
      x5t: option(string),
    };

    let to_pub: t => result(Nocrypto.Rsa.pub_, [ | `Msg(string)]);

    let of_pub: Nocrypto.Rsa.pub_ => result(t, [ | `Msg(string)]);

    let of_pub_pem: string => result(t, [ | `Msg(string)]);

    let to_pub_pem: t => result(string, [ | `Msg(string)]);

    let to_json: t => Yojson.Basic.t;

    let from_json: Yojson.Basic.t => t;

    let from_string: string => t;
  };

  /**
  {1 Private keys}

  These keys are not safe to show and should be used to sign content.
  */
  module Priv: {

    /**
    [t] describes a Private JSON Web Key
    */
    type t = {
      kty: string,
      n: string,
      e: string,
      d: string,
      p: string,
      q: string,
      dp: string,
      dq: string,
      qi: string,
      alg: option(string),
      kid: string,
    };

    /**
    [of_priv priv] takes a private key generated by Nocrypto and returns a result t or a message of what went wrong.
    */
    let of_priv: Nocrypto.Rsa.priv => result(t, [ | `Msg(string)]);

    /**
    [to_priv t] takes a private JWK and returns a result Nocrypto.Rsa.priv or a message of what went wrong.
    */
    let to_priv: t => result(Nocrypto.Rsa.priv, [ | `Msg(string)]);

    /**
    [of_priv_pem pem] takes a PEM as a string and returns a result a result t or a message of what went wrong.
    */  
    let of_priv_pem: string => result(t, [ | `Msg(string)]);

    /**
    [to_priv_pem t] takes a private JWK and returns a result PEM string or a message of what went wrong.
    */
    let to_priv_pem: t => result(string, [ | `Msg(string)]);
  };
};

/**

{1 JSON Web Key Set}
*/

module Jwks: {
  type t = {keys: list(Jwk.Pub.t)};

  let to_json: t => Yojson.Basic.t;

  let from_json: Yojson.Basic.t => t;

  let from_string: string => t;
};

/**

{1 JSON Web Token}
*/


module Jwt: {
  type header;

  let make_header: Jwk.Pub.t => header;

  type payload = Yojson.Basic.t;
  type claim = (string, Yojson.Basic.t);

  let empty_payload: payload;

  type signature;

  type t;

  let add_claim: (string, Yojson.Basic.t, payload) => payload;

  let sign:
    (header, Nocrypto.Rsa.priv, payload) => result(t, [ | `Msg(string)]);

  let to_string: t => string;
  let from_string: string => result(t, [ | `Msg(string)]);

  let verify: (~jwks: list(Jwk.Pub.t), t) => result(t, [ | `Msg(string)]);
};