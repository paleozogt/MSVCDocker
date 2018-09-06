class HelloWorld {
    private native String helloWorld();

    public static void main(String[] args) {
        System.loadLibrary("HelloWorld");
        System.out.println(new HelloWorld().helloWorld());
    }
}
