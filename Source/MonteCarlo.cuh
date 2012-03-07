/*
	Copyright (c) 2011, T. Kroes <t.kroes@tudelft.nl>
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	- Neither the name of the TU Delft nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#pragma once

#include "Geometry.cuh"

#include "RNG.cuh"

DEVICE float SphericalTheta(const Vec3f& Wl)
{
	return acosf(Clamp(Wl[1], -1.f, 1.f));
}

DEVICE float SphericalPhi(const Vec3f& Wl)
{
	float p = atan2f(Wl[2], Wl[0]);
	return (p < 0.f) ? p + 2.f * PI_F : p;
}

DEVICE float CosTheta(const Vec3f& Ws)
{
	return Ws[2];
}

DEVICE float AbsCosTheta(const Vec3f &Ws)
{
	return fabsf(CosTheta(Ws));
}

DEVICE float SinTheta(const Vec3f& Ws)
{
	return sqrtf(max(0.f, 1.f - Ws[2] * Ws[2]));
}

DEVICE float SinTheta2(const Vec3f& Ws)
{
	return 1.f - CosTheta(Ws) * CosTheta(Ws);
}

DEVICE float CosPhi(const Vec3f& Ws)
{
	return Ws[0] / SinTheta(Ws);
}

DEVICE float SinPhi(const Vec3f& Ws)
{
	return Ws[1] / SinTheta(Ws);
}

DEVICE bool SameHemisphere(const Vec3f& Ww1, const Vec3f& Ww2)
{
   return (Ww1[2] * Ww2[2]) > 0.0f;
}

DEVICE bool SameHemisphere(const Vec3f& W1, const Vec3f& W2, const Vec3f& N)
{
   return (Dot(W1, N) * Dot(W2, N)) >= 0.0f;
}

DEVICE bool InShadingHemisphere(const Vec3f& W1, const Vec3f& W2, const Vec3f& N)
{
   return Dot(W1, N) >= 0.0f && Dot(W2, N) >= 0.0f;
}

DEVICE Vec3f SampleHemisphere(Vec2f U, float Radius, Vec3f* pN = NULL)
{
	float z		= U[0];
	float r		= sqrtf(max(0.0f, 1.0f - z * z));
	float phi	= 2 * PI_F * U[1];
	float x		= r * cosf(phi);
	float y		= r * sinf(phi);

	if (pN)
		*pN = Vec3f(x, y, z);

	return Vec3f(x, y, z);
}

DEVICE Vec2f ConcentricSampleDisk(const Vec2f& U)
{
	float r, theta;
	// Map uniform random numbers to $[-1,1]^2$
	float sx = 2 * U[0] - 1;
	float sy = 2 * U[1] - 1;
	// Map square to $(r,\theta)$
	// Handle degeneracy at the origin
	
	if (sx == 0.0 && sy == 0.0)
	{
		return Vec2f(0.0f);
	}

	if (sx >= -sy)
	{
		if (sx > sy)
		{
			// Handle first region of disk
			r = sx;
			if (sy > 0.0)
				theta = sy/r;
			else
				theta = 8.0f + sy/r;
		}
		else
		{
			// Handle second region of disk
			r = sy;
			theta = 2.0f - sx/r;
		}
	}
	else
	{
		if (sx <= sy)
		{
			// Handle third region of disk
			r = -sx;
			theta = 4.0f - sy/r;
		}
		else
		{
			// Handle fourth region of disk
			r = -sy;
			theta = 6.0f + sx/r;
		}
	}
	
	theta *= PI_F / 4.f;

	return Vec2f(r*cosf(theta), r*sinf(theta));
}

DEVICE Vec3f CosineWeightedHemisphere(const Vec2f& U)
{
	const Vec2f ret = ConcentricSampleDisk(U);
	return Vec3f(ret[0], ret[1], sqrtf(max(0.f, 1.f - ret[0] * ret[0] - ret[1] * ret[1])));
}

DEVICE Vec3f CosineWeightedHemisphere(const Vec2f& U, const Vec3f& N)
{
	const Vec3f Wl = CosineWeightedHemisphere(U);

	const Vec3f u = Normalize(Cross(N, N));
	const Vec3f v = Normalize(Cross(N, u));

	return Vec3f(	u[0] * Wl[0] + v[0] * Wl[1] + N[0] * Wl[2],
						u[1] * Wl[0] + v[1] * Wl[1] + N[1] * Wl[2],
						u[2] * Wl[0] + v[2] * Wl[1] + N[2] * Wl[2]);
}

DEVICE float CosineWeightedHemispherePdf(const float& CosTheta, const float& Phi)
{
	return CosTheta * INV_PI_F;
}

DEVICE Vec3f SphericalDirection(const float& SinTheta, const float& CosTheta, const float& Phi)
{
	return Vec3f(SinTheta * cosf(Phi), SinTheta * sinf(Phi), CosTheta);
}

DEVICE Vec3f SphericalDirection(float sintheta, float costheta, float phi, const Vec3f& x, const Vec3f& y, const Vec3f& z)
{
	return sintheta * cosf(phi) * x + sintheta * sinf(phi) * y + costheta * z;
}

DEVICE Vec3f SphericalDirection(const float& SinTheta, const float& CosTheta, const float& Phi, const Vec3f& N)
{
	const Vec3f Wl = SphericalDirection(SinTheta, CosTheta, Phi);

	const Vec3f u = Normalize(Cross(N, Vec3f(0.0072f, 1.0f, 0.0034f)));
	const Vec3f v = Normalize(Cross(N, u));

	return Vec3f(	u[0] * Wl[0] + v[0] * Wl[1] + N[0] * Wl[2],
						u[1] * Wl[0] + v[1] * Wl[1] + N[1] * Wl[2],
						u[2] * Wl[0] + v[2] * Wl[1] + N[2] * Wl[2]);
}

DEVICE Vec2f UniformSampleTriangle(const Vec2f& U)
{
	float su1 = sqrtf(U[0]);

	return Vec2f(1.0f - su1, U[1] * su1);
}

DEVICE Vec3f UniformSampleSphereSurface(const Vec2f& U)
{
	float z = 1.f - 2.f * U[0];
	float r = sqrtf(max(0.f, 1.f - z*z));
	float phi = 2.f * PI_F * U[1];
	float x = r * cosf(phi);
	float y = r * sinf(phi);
	return Vec3f(x, y, z);
}

DEVICE Vec3f UniformSampleHemisphere(const Vec2f& U)
{
	float z = U[0];
	float r = sqrtf(max(0.f, 1.f - z*z));
	float phi = 2 * PI_F * U[1];
	float x = r * cosf(phi);
	float y = r * sinf(phi);
	return Vec3f(x, y, z);
}

DEVICE inline Vec3f UniformSampleHemisphere(const Vec2f& U, const Vec3f& N)
{
	const Vec3f Wl = UniformSampleHemisphere(U);

	const Vec3f u = Normalize(Cross(N, Vec3f(0.0072f, 1.0f, 0.0034f)));
	const Vec3f v = Normalize(Cross(N, u));

	return Vec3f(	u[0] * Wl[0] + v[0] * Wl[1] + N[0] * Wl[2],
						u[1] * Wl[0] + v[1] * Wl[1] + N[1] * Wl[2],
						u[2] * Wl[0] + v[2] * Wl[1] + N[2] * Wl[2]);
}

DEVICE float PowerHeuristic(int nf, float fPdf, int ng, float gPdf)
{
	float f = nf * fPdf, g = ng * gPdf;
	return (f * f) / (f * f + g * g); 
}