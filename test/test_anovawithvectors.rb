require(File.dirname(__FILE__)+'/test_helpers.rb')

class StatsampleAnovaTestCase < Test::Unit::TestCase
  context(Statsample::Anova::OneWayWithVectors) do
    context("when initializing") do
      setup do
        @v1=10.times.map {rand(100)}.to_scale
        @v2=10.times.map {rand(100)}.to_scale
        @v3=10.times.map {rand(100)}.to_scale
      end
      should "be the same using [] or args*" do
        a1=Statsample::Anova::OneWayWithVectors.new(@v1,@v2,@v3)
        a2=Statsample::Anova::OneWayWithVectors.new([@v1,@v2,@v3])
        assert_equal(a1.f,a2.f)
      end
      should "detect optional hash" do
        a1=Statsample::Anova::OneWayWithVectors.new(@v1,@v2,@v3, {:name=>'aaa'})
        assert_equal('aaa', a1.name)
      end
      should "omit incorrect arguments" do
        a1=Statsample::Anova::OneWayWithVectors.new(@v1,@v2,@v3, {:name=>'aaa'})
        a2=Statsample::Anova::OneWayWithVectors.new(@v1,nil,nil,@v2,@v3, {:name=>'aaa'})
        assert_equal(a1.f,a2.f)
      end
    end
    setup do
      @v1=[3,3,2,3,6].to_vector(:scale)
      @v2=[7,6,5,6,7].to_vector(:scale)
      @v3=[9,8,9,7,8].to_vector(:scale)
      @anova=Statsample::Anova::OneWayWithVectors.new(@v1,@v2,@v3)
    end
    should "have correct value for sst" do
     assert_in_delta(72.933, @anova.sst,0.001)
    end
    should "have correct value for sswg" do
      assert_in_delta(14.8,@anova.sswg,0.001)
    end
    should "have correct value for ssb" do
      assert_in_delta(58.133,@anova.ssbg,0.001)
    end
    should "sst=sswg+ssbg" do
      assert_in_delta(@anova.sst,@anova.sswg+@anova.ssbg,0.00001)
    end
    should "df total equal to number of n-1" do
      assert_equal(@v1.n+@v2.n+@v3.n-1,@anova.df_total)
    end
    should "df wg equal to number of n-k" do
      assert_equal(@v1.n+@v2.n+@v3.n-3,@anova.df_wg)
    end
    should "df bg equal to number of k-1" do
      assert_equal(2,@anova.df_bg)
    end
    should "f=(ssbg/df_bg)/(sswt/df_wt)" do
      assert_in_delta((@anova.ssbg.quo(@anova.df_bg)).quo( @anova.sswg.quo(@anova.df_wg)), @anova.f, 0.001)
    end
    should "p be correct" do
      assert(@anova.probability<0.01)
    end
    should "be correct using more values" do
      anova2=Statsample::Anova::OneWayWithVectors.new([@v1,@v1,@v1,@v1,@v2])
      assert_in_delta(3.960, anova2.f,0.001)
      assert_in_delta(0.016, anova2.probability,0.001)
    end
  end
end