%{
  math: 8 + 8,
  func: (fn ->
    value = :rand.uniform(888)
    :ets.insert(:eon_test_bucket, {"unsafe", value})
    value
  end).()
}
