package vg

background_vertex :: proc() -> cstring {
    return `#version 330 core
    layout (location = 0) in vec3 aPos;
    
    uniform mat4 u_projection;
    uniform mat4 u_view;
    
    out vec3 WorldPos;
    
    void main()
    {
        WorldPos = aPos;
        
        mat4 rotView = mat4(mat3(u_view));
        vec4 clipPos = u_projection * rotView * vec4(WorldPos, 1.0);
        
        gl_Position = clipPos.xyww;
    }`
}

background_fragment :: proc() -> cstring {
    return `#version 330 core
    out vec4 FragColor;
    in vec3 WorldPos;
    
    uniform samplerCube environmentMap;
    
    void main()
    {		
        vec3 envColor = texture(environmentMap, WorldPos).rgb;
        
        // HDR tonemap and gamma correct
        envColor = envColor / (envColor + vec3(1.0));
        envColor = pow(envColor, vec3(1.0/2.2)); 
        
        FragColor = vec4(envColor, 1.0);
    }`
}