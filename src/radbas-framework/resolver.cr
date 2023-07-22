class Radbas::Framework::Resolver(T)
  def initialize(&@block : T.class -> T)
  end

  def call(klass : T.class) : T
    @block.call(klass)
  end
end
