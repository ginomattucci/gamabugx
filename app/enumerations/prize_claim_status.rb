class PrizeClaimStatus < EnumerateIt::Base
  associate_values claimed: 0,
                   waiting_shipping: 1,
                   shipped: 2,
                   delivered: 3,
                   canceled: 4
  sort_by :value
end
