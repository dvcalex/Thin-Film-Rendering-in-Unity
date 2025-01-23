#version 300 es
precision highp float;
precision mediump int;

uniform mat4 viewMatrix; // Supplied by ThreeJS
//uniform vec3 cameraPosition; // Supplied by ThreeJS

uniform samplerCube tEnv;
uniform int tonemapFlag;
uniform float exposure;
uniform vec3 layer1;
uniform vec3 layer2;

in vec3 vNormal;
in vec3 vPosition;
in vec2 vUv;

out vec4 fragColor;

#define saturate(a) clamp(a, 0.0, 1.0)
#define one_over_pi_by_2 0.63661977236
#define TWO_M_PI 6.283185307
#define number_layer 4
#define wavelengths vec3(580.f, 550.f, 480.f)
#define eps 1e-8

vec2 interface_r(int p, vec2 n_i, vec2 n_f, float th_i, float th_f) {
    if (p == 0) {
        vec2 den = vec2(n_i.x * th_i + n_f.x * th_f, n_i.y * th_i + n_f.y * th_f);
        vec2 num = vec2(n_i.x * th_i - n_f.x * th_f, n_i.y * th_i - n_f.y * th_f);
        vec2 numxden = vec2(den.x * num.x + den.y * num.y, num.y * den.x - num.x * den.y);
        return numxden / (length(den) * length(den));
    }
    else {
        vec2 den = vec2(n_f.x * th_i + n_i.x * th_f, n_f.y * th_i + n_i.y * th_f);
        vec2 num = vec2(n_f.x * th_i - n_i.x * th_f, n_f.y * th_i - n_i.y * th_f);
        vec2 numxden = vec2(den.x * num.x + den.y * num.y, num.y * den.x - num.x * den.y);
        return numxden / (length(den) * length(den));
    }
}


vec2 interface_t(int p, vec2 n_i, vec2 n_f, float th_i, float th_f) {
    if (p == 0)
    {
        vec2 den = vec2(n_i.x * th_i + n_f.x * th_f, n_i.y * th_i + n_f.y * th_f);
        vec2 num = 2.f * th_i * vec2(n_i.x * den.x + n_i.y * den.y, -n_i.x * den.y + n_i.y * den.x);
        return num / (length(den) * length(den));
    }
    else {
        vec2 den = vec2(n_f.x * th_i + n_i.x * th_f, n_f.y * th_i + n_i.y * th_f);
        vec2 num = 2.f * th_i * vec2(n_i.x * den.x + n_i.y * den.y, -n_i.x * den.y + n_i.y * den.x);
        return num / (length(den) * length(den));
    }
}

vec3 tonemap(vec3 color) {
    if (tonemapFlag == 0) return color;
    color *= exposure;
    return saturate(color);
}

vec2 retreive_r(mat4 M) {
    float den = M[0][0] * M[0][0] + M[1][0] * M[1][0];
    float num_real = M[0][2] * M[0][0] + M[1][2] * M[1][0];
    float num_imag = M[1][2] * M[0][0] - M[0][2] * M[1][0];
    return vec2(num_real, num_imag) / den;
}

mat4 complex_time_matrix(vec2 t, mat4 M) {
    float den = length(t) * length(t);
    return mat4(
    M[0][0] * t.x + M[0][1] * t.y, M[0][1] * t.x - M[0][0] * t.y, M[0][2] * t.x + M[0][3] * t.y, M[0][3] * t.x - M[0][2] * t.y,
    M[0][1] * t.x - M[0][0] * t.y, M[0][0] * t.x + M[0][1] * t.y, M[0][3] * t.x - M[0][2] * t.y, M[0][2] * t.x + M[0][3] * t.y,
    M[2][0] * t.x + M[2][1] * t.y, M[2][1] * t.x - M[2][0] * t.y, M[2][2] * t.x + M[2][3] * t.y, M[2][3] * t.x - M[2][2] * t.y,
    M[2][1] * t.x - M[2][0] * t.y, M[2][0] * t.x + M[2][1] * t.y, M[2][3] * t.x - M[2][2] * t.y, M[2][2] * t.x + M[2][3] * t.y) / den;
}

mat4 Bs_m(vec2 rs) {
    return mat4(1.f, 0.f, rs.x, rs.y,
    0.f, 1.f, rs.y, rs.x,
    rs.x, rs.y, 1.f, 0.f,
    rs.y, rs.x, 0.f, 1.f);
}

mat4 Bp_m(vec2 rp) {
    return mat4(1.f, 0.f, rp.x, rp.y,
    0.f, 1.f, rp.y, rp.x,
    rp.x, rp.y, 1.f, 0.f,
    rp.y, rp.x, 0.f, 1.f);
}

mat4 A_m(vec2 delta) {
    return mat4(exp(delta.y) * cos(delta.x), -exp(delta.y) * sin(delta.x), 0.f, 0.f,
    -exp(delta.y) * sin(delta.x), exp(delta.y) * cos(delta.x), 0.f, 0.f,
    0.f, 0.f, exp(-delta.y) * cos(delta.x), exp(-delta.y) * sin(delta.x),
    0.f, 0.f, exp(-delta.y) * sin(delta.x), exp(-delta.y) * cos(delta.x));
}


void main() {
    vec3 viewDirection = normalize(vPosition);
    //vec3 viewDirection = normalize(vPosition-cameraPosition);
    vec3 N = normalize(vNormal);
    float incidentAngle = acos(dot(-viewDirection, N));
    float ct[number_layer], d[number_layer];
    vec2 ior[number_layer], t_listp[number_layer - 1], t_lists[number_layer - 1], r_listp[number_layer - 1], r_lists[number_layer - 1], delta[number_layer];
    
    vec3 R = vec3(0.f);
    vec3 reflectDirection = reflect(viewDirection, N);
    //vec3 reflectDirectionWorld = reflectDirection;
    mat4 Ms[number_layer], Mp[number_layer];
    mat4 A, Bp, Bs;
    
    Ms[0] = mat4(1.f);
    Mp[0] = mat4(1.f);
    
    ior[0] = vec2(1.f, 0.f); //air
    ior[1] = vec2(layer1.x, layer1.y);
    ior[2] = vec2(layer2.x, layer2.y);
    ior[3] = vec2(1.49f, 0.f); //polypropylène
    
    d[0] = 1000000.f;
    d[1] = layer1.z;
    d[2] = layer2.z;
    d[3] = 1000000.f;
    
    ct[0] = dot(-viewDirection, N);
    
    float ctsqr = (1.f - (1.f - ct[0] * ct[0]) * (ior[0].x / ior[1].x) * (ior[0].x / ior[1].x));
    
    if (ctsqr < 0.f)
    R = vec3(1.f);
    else {
        for (int i = 0;i < number_layer - 1; ++i)
        {
            ct[i + 1] = sqrt(1.f - (1.f - ct[0] * ct[0]) * (ior[0].x / ior[i + 1].x) * (ior[0].x / ior[i + 1].x));
            t_listp[i] = interface_t(1, ior[i], ior[i + 1], ct[i], ct[i + 1]);
            r_listp[i] = interface_r(1, ior[i], ior[i + 1], ct[i], ct[i + 1]);
            t_lists[i] = interface_t(0, ior[i], ior[i + 1], ct[i], ct[i + 1]);
            r_lists[i] = interface_r(0, ior[i], ior[i + 1], ct[i], ct[i + 1]);
        }
        
        for (int wavelength = 0;wavelength < 3; ++wavelength)
        {
            for (int i = 1;i < number_layer - 1; ++i)
            {
                delta[i] = (TWO_M_PI * ior[i] * ct[i] * d[i] / wavelengths[wavelength]);
            }
            for (int i = 1;i < number_layer - 1; ++i)
            {
                A = A_m(delta[i]);
                Bp = Bp_m(r_listp[i]);
                Bs = Bs_m(r_lists[i]);
                
                Ms[i] = complex_time_matrix(t_lists[i], Ms[i - 1]) * A * Bs;
                Mp[i] = complex_time_matrix(t_listp[i], Mp[i - 1]) * A * Bp;
            }
            
            Bp = Bp_m(r_listp[0]);
            Bs = Bs_m(r_lists[0]);
            
            Ms[number_layer - 1] = complex_time_matrix(t_lists[0], Bs) * Ms[number_layer - 2];
            Mp[number_layer - 1] = complex_time_matrix(t_listp[0], Bp) * Mp[number_layer - 2];
            
            vec2 rs = retreive_r(Ms[number_layer - 1]);
            vec2 rp = retreive_r(Mp[number_layer - 1]);
            
            R[wavelength] = saturate(0.5f * (length(rs) * length(rs) + length(rp) * length(rp)));
        }
    }
    
    mat3 cameraCoordinateMatrix = mat3(viewMatrix);
    vec3 reflectDirectionWorld = vec3(
    -dot(cameraCoordinateMatrix[0], reflectDirection),
    dot(cameraCoordinateMatrix[1], reflectDirection),
    dot(cameraCoordinateMatrix[2], reflectDirection)
    );
    
    vec3 vColor = texture(tEnv, reflectDirectionWorld).rgb * R * ct[0] * exposure;
    fragColor = vec4(vColor, 1.f);
}