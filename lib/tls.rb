module TLS
	# RFC5246 s7.4.1.4.1 (I shit you not, five levels of headings)
	HashAlgorithm = { :none   => 0,
	                  :md5    => 1,
	                  :sha1   => 2,
	                  :sha224 => 3,
	                  :sha256 => 4,
	                  :sha384 => 5,
	                  :sha512 => 6
	                }
	HashAlgorithm_len = 1

	# RFC5246 s7.4.1.4.1
	SignatureAlgorithm = { :anonymous => 0,
	                       :rsa       => 1,
	                       :dsa       => 2,
	                       :ecdsa     => 3
	                     }
	SignatureAlgorithm_len = 1
end

require 'tls/digitally_signed'
require 'tls/opaque'
