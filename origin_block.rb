class OriginBlock < Block
  def initialize
  end

  def previous_block_hash
    nil
  end

  def block_hash
    'origin'
  end

  def nonce
    'origin'
  end

  def valid?
    true
  end

  def to_json
    {
      previous_block_hash: previous_block_hash,
      txns: txns.to_json,
      nonce: 1
    }.to_json
  end

  def txns
    [
      Txn.new(
        from: 'origin',
        to: public_key,
        amount: 1_000_000,
        signature: 'origin',
        timestamp: 0
      )
    ]
  end

  def private_key
    <<~TEXT
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAz2T5ELLjsutm587JEb7kYxwh6sC4Lpbl3HE1e5NXJWQCN/w5
      r/GeCNaPU8t0IotKK04ejVdzchafZGznjtVsU3Uqo4JRTDPss4vwXlo7bJwO3GzD
      kZKMgA36DqqXutTsm8xj5qVOB4hKoZTQTqfyvLn68XIZhSanIN7D+Yr/Tq+AX/3v
      VdBP7MoAuvWbyCb6Pc9r5w+cMgF0ICFQr2M+X1jguHoD/i7ns45bw60ylzyKLWs1
      qR4x5MQ2J/t4LEdkGpyx4qD4fILbajVDpGsP34I37Sv1uTe4yQzplv5nnOWeUviB
      8FXYHmptrnUsTcIcfuchWFrYpMlhXL8AfJbJHQIDAQABAoIBACwUMN98tepsH9X6
      3D9aTB5Id2j2hu7YAYjFwvE90pLO263cfMJJXyZPu+y6XDePVTc5BkNSJ+ZCqqPk
      hZ6U+84NI//WjcLdclyCzJaxJNojnQD6WOKSvCvnTJNbbJ437QX7/euijKALNpl7
      EH73MR8thAlXD9d97J2O2yYphbPKNO+ZyVLCh0MWCJMZgQ8CByPK6gf1DtqRoXqa
      YYVDuqaa/Zt2OoRRcIW3Rc6ZGpCCE+6iAadeoBdOnQyX1JWZnjKZ4k9D2RCr0KQn
      FUBgPB6A7TtMsKPujK03AmM9Q2YPIm44T9K56Y7hNq1V9Rt0Qump9Vyqelhy9dvC
      CKaUX70CgYEA++qXBFf0enutzxQM/FWIhm0ikpzLio94h/6VRUO46RwMgXqnzsQ/
      f+7DqDdWoreF62NASmAZ2C1Nmm0UQTiebAkK2n4rfnFyCDFO88/dYKsnC+6h6uYs
      94e34o2F5pH1kYKCox6Jy454YYwePg0MRQTBAJCW4049sAdQd9e/tjsCgYEA0sGf
      4CgKhAx2M6cgtmAN/cn7+SlY/NGFVm4wkgjIPLPWzFSYeui85ysl1TPO+kuDJrUI
      dA3jChT/w3+PUsm3MrGAZsN+T5jE+DOFCwxE9+EsG7mL034N7FusxpiOmikpReSI
      8mknAEn7K+a06Y7/bJYykfI9+c40iMIbuq2uEIcCgYAIVWJZim9T/fNp/kfPsSSr
      DcEvCHDTTJu4I/vcJrlfPMZNIjma5XMUUFm4ntwG1ftgJhBiZXt1Y0pF6YXaAn17
      JXFueO4HaMlU7AyolB/GquLHykUg+CxUo/C5VeUwE3QENEUOEFyOl0/0KiZ19wiI
      3/dihWX4bwYrZJKM5F47MQKBgCSg3iZZDyrP96MWgsrver8G4bH2C680wtW4pNxc
      hmB2aPhuI2oJFPugNh0NugUqJosNn4B8AV95MtJJUyFySVKYIta5VzSCOolgetjm
      sv3Zto7C+pgxKj5P2IFTdkU4riGljF+FAvA761k/6WVGIwI+QF+5GChYPC0gfy08
      jin1AoGBAIHz/wM579wEB7BwtNZnA2V/2xmRdPLwvTOb/zc+bBn0AeJd1QyMm+7R
      egwYy+f8uxHFCXmH2GO83eUBdwLG2GcTtKscr/NtZcqikJR8ZCM4X7cBZU967AXZ
      BmX8dAYVSCV9Vr1P17BV5T4PJRXWH4wPT/KX0uFm/ELrs9OuLSN9
      -----END RSA PRIVATE KEY-----
    TEXT
  end

  def public_key
    <<~TEXT
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAz2T5ELLjsutm587JEb7k
      Yxwh6sC4Lpbl3HE1e5NXJWQCN/w5r/GeCNaPU8t0IotKK04ejVdzchafZGznjtVs
      U3Uqo4JRTDPss4vwXlo7bJwO3GzDkZKMgA36DqqXutTsm8xj5qVOB4hKoZTQTqfy
      vLn68XIZhSanIN7D+Yr/Tq+AX/3vVdBP7MoAuvWbyCb6Pc9r5w+cMgF0ICFQr2M+
      X1jguHoD/i7ns45bw60ylzyKLWs1qR4x5MQ2J/t4LEdkGpyx4qD4fILbajVDpGsP
      34I37Sv1uTe4yQzplv5nnOWeUviB8FXYHmptrnUsTcIcfuchWFrYpMlhXL8AfJbJ
      HQIDAQAB
      -----END PUBLIC KEY-----
    TEXT
  end
end