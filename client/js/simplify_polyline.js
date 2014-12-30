"use strict";
define([], function() {

//
// The points are of datatype [___, x, y]
//
// This matches the events in the PaintMark object.
//
    
    function vec_min_2d(a, b) {
      return [undefined, a[1] - b[1], a[2] - b[2]];
      }
    
    function dot_prod_2d(a, b) {
      return (a[1] * b[1]) + (a[2] * b[2]);
      }
    
    function norm_squared_2d(a) {
        return (a[1] * a[1]) + (a[2] * a[2]);
        }
    
    function dist_squared_2d(a, b) {
        return norm_squared_2d(vec_min_2d(a, b));
        }
    
    function simplify_2d(tolerance2, points, markers, j, k) {
        var i, max_i; // integer
        var max_d2; // float
        var cu, cw, b; // float
        var dv2; // float
        var p0, p1, pb, u, w; // point
    
        if(! (k <= (j + 1))) {
            p0 = points[j];
            p1 = points[k];
            u = vec_min_2d(p1, p0); // segment vector
            cu = dot_prod_2d(u, u); // segment length squared
            max_d2 = 0;
            max_i = 0;
            for(i=j+1; i<k; i++) {
                w = vec_min_2d(points[i], p0);
                cw = dot_prod_2d(w, u);
                if( cw <= 0 ) {
                    dv2 = dist_squared_2d(points[i], p0);
                    }
                else {
                    if( cw > cu ) {
                        dv2 = dist_squared_2d(points[i], p1);
                        }
                    else {
                        if( cu == 0 ){
                            b = 0;
                            }
                        else {
                            b = cw / cu;
                            }
                        pb = [undefined, (p0[1] + (b * u[1])), (p0[2] + (b * u[2]))];
                        dv2 = dist_squared_2d(points[i], pb);
                        }
                    }
                if( dv2 > max_d2 ) {
                    max_i = i;
                    max_d2 = dv2;
                    }
                }
            if( max_d2 > tolerance2 ) {
                markers[max_i] = true;
                simplify_2d(tolerance2, points, markers, j, max_i);
                simplify_2d(tolerance2, points, markers, max_i, k);
                }
            }
        }
    
    function poly_simplify_2d(tolerance, points) {
        if(tolerance == 0 || points.length < 2) {
            return points.slice();
            }
        var N = points.length;
        var markers = new Array(N);
        markers[0] = true;
        markers[N-1] = true;
        simplify_2d((tolerance * tolerance), points, markers, 0, N-1);
        var output = [];
        for(var i=0; i<N; i++ ) {
            if( markers[i] ) {
                output.push(points[i]);
                }
            }
        return output;
        }
    
    function getControlPoints(x0,y0, x1,y1, x2,y2, t){
        // from http://scaledinnovation.com/analytics/splines/aboutSplines.html
        var d01 = Math.sqrt( Math.pow(x1 - x0, 2) + Math.pow(y1 - y0, 2) );
        var d12 = Math.sqrt( Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2) );
        var fa = t * d01 / (d01 + d12);   // scaling factor for triangle Ta
        var fb = t * d12 / (d01 + d12);   // ditto for Tb, simplifies to fb=t-fa
        var p1x = x1 - fa * (x2 - x0);    // x2-x0 is the width of triangle T
        var p1y = y1 - fa * (y2 - y0);    // y2-y0 is the height of T
        var p2x = x1 + fb * (x2 - x0);
        var p2y = y1 + fb * (y2 - y0);  
        return [p1x, p1y, p2x, p2y];
        }
    
    
    function simple_spline_interpolation(rawpoints, penwidth, smoothfactor) {
        var output = [];
        var points = poly_simplify_2d(penwidth, rawpoints);
        var N = points.length;
        for(var i=1; i<N-1; i++) {
            var p0 = points[i-1];
            var p1 = points[i];
            var p2 = points[i+1];
            p1.controls = getControlPoints(
                p0[1], p0[2],
                p1[1], p1[2],
                p2[1], p2[2],
                smoothfactor
                );
            if(i == 1) {
                output.push(['M', p1[1], p1[2]]);
                }
            else {
                output.push(['C', p0.controls[2],  p0.controls[3],
                                    p1.controls[0],  p1.controls[1],
                                    p1[1], p1[2]
                                  ]);
                }
            }
        return output;
        }
        
        return {
            simple_spline_interpolation: simple_spline_interpolation,
            poly_simplify_2d: poly_simplify_2d
        }
});
