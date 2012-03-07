/*
	Copyright (c) 2011, T. Kroes <t.kroes@tudelft.nl>
	All rights reserved.

	Redistribution and use in source and binary forms, with or witDEVut modification, are permitted provided that the following conditions are met:

	- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	- Neither the name of the TU Delft nor the names of its contributors may be used to endorse or promote products derived from this software witDEVut specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT DEVLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT DEVLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) DEVWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#pragma once

#include "Vector.cuh"
#include "Color.cuh"
#include "Ray.cuh"

using namespace std;

HOST_DEVICE float Lerp(float t, float v1, float v2)
{
	return (1.f - t) * v1 + t * v2;
}

HOST_DEVICE void swap(int& a, int& b)
{
	int t = a; a = b; b = t;
}

HOST_DEVICE void swap(float& a, float& b)
{
	float t = a; a = b; b = t;
}

HOST_DEVICE void Swap(float* pF1, float* pF2)
{
	const float TempFloat = *pF1;

	*pF1 = *pF2;
	*pF2 = TempFloat;
}

HOST_DEVICE void Swap(float& F1, float& F2)
{
	const float TempFloat = F1;

	F1 = F2;
	F2 = TempFloat;
}

HOST_DEVICE void Swap(int* pI1, int* pI2)
{
	const int TempInt = *pI1;

	*pI1 = *pI2;
	*pI2 = TempInt;
}

HOST_DEVICE void Swap(int& I1, int& I2)
{
	const int TempInt = I1;

	I1 = I2;
	I2 = TempInt;

}

class CResolution2D
{
public:
	// ToDo: Add description
	HOST_DEVICE CResolution2D(const float& Width, const float& Height)
	{
		m_XY		= Vec2i(Width, Height);

		Update();
	}

	// ToDo: Add description
	HOST_DEVICE CResolution2D(void)
	{
		m_XY		= Vec2i(640, 480);

		Update();
	}

	// ToDo: Add description
	HOST_DEVICE ~CResolution2D(void)
	{
	}

	// ToDo: Add description
	HOST_DEVICE CResolution2D& CResolution2D::operator=(const CResolution2D& Other)
	{
		m_XY				= Other.m_XY;
		m_InvXY				= Other.m_InvXY;
		m_NoElements		= Other.m_NoElements;
		m_AspectRatio		= Other.m_AspectRatio;
		m_DiagonalLength	= Other.m_DiagonalLength;

		return *this;
	}

	HOST_DEVICE int operator[](int i) const
	{
		return m_XY[i];
	}

	HOST_DEVICE int& operator[](int i)
	{
		return m_XY[i];
	}

	HOST_DEVICE bool operator == (const CResolution2D& Other) const
	{
		return GetResX() == Other.GetResX() && GetResY() == Other.GetResY();
	}

	HOST_DEVICE bool operator != (const CResolution2D& Other) const
	{
		return GetResX() != Other.GetResX() || GetResY() != Other.GetResY();
	}

	// ToDo: Add description
	HOST_DEVICE void Update(void)
	{
		m_InvXY				= Vec2f(m_XY[0] != 0.0f ? 1.0f / m_XY[0] : 0.0f, m_XY[1] != 0.0f ? 1.0f / m_XY[1] : 0.0f);
		m_NoElements		= m_XY[0] * m_XY[1];
		m_AspectRatio		= (float)m_XY[1] / (float)m_XY[0];
		m_DiagonalLength	= sqrtf(powf(m_XY[0], 2.0f) + powf(m_XY[1], 2.0f));
	}

	// ToDo: Add description
	HOST_DEVICE Vec2i ToVector(void) const
	{
		return Vec2i(m_XY[0], m_XY[1]);
	}

	HOST_DEVICE void Set(const Vec2i& Resolution)
	{
		m_XY = Resolution;

		Update();
	}

	HOST_DEVICE int GetResX(void) const				{ return m_XY[0];				}
	HOST_DEVICE void	SetResX(const int& Width)		{ m_XY[0] = Width; Update();	}
	HOST_DEVICE int GetResY(void) const				{ return m_XY[1];				}
	HOST_DEVICE void	SetResY(const int& Height)		{ m_XY[1] = Height; Update();	}
	HOST_DEVICE Vec2f GetInv(void) const				{ return m_InvXY;				}
	HOST_DEVICE int GetNoElements(void) const		{ return m_NoElements;			}
	HOST_DEVICE float GetAspectRatio(void) const		{ return m_AspectRatio;			}

private:
	Vec2i	m_XY;					/*!< Resolution width and height */
	Vec2f	m_InvXY;				/*!< Resolution width and height reciprocal */
	int		m_NoElements;			/*!< No. elements */
	float	m_AspectRatio;			/*!< Aspect ratio of image plane */
	float	m_DiagonalLength;		/*!< Diagonal length */
};

inline float RandomFloat(void)
{
	return (float)rand() / RAND_MAX;
}

struct ScatterEvent
{
	enum SampleType
	{
		ErVolume,
		Light,
		Reflector
	};

	SampleType	Type;
	bool		Valid;
	float		T;
	Vec3f		P;
	Vec3f		N;
	Vec3f		Wo;
	ColorXYZf	Le;
	Vec2f		UV;
	int			ReflectorID;
	int			LightID;

	HOST_DEVICE ScatterEvent(SampleType Type)
	{
		this->Type = Type;
		this->SetInvalid();
	}

	HOST_DEVICE void SetValid(float T, Vec3f P, Vec3f N, Vec3f Wo, ColorXYZf Le, Vec2f UV = Vec2f(0.0f))
	{
		this->Valid		= true;
		this->T			= T;
		this->P			= P;
		this->N			= N;
		this->Wo		= Wo;
		this->Le		= Le;
		this->UV		= UV;
	}

	HOST_DEVICE void SetInvalid()
	{
		this->Valid		= false;
		this->T			= 0.0f;
		this->P			= Vec3f(0.0f);
		this->N			= Vec3f(0.0f);
		this->Wo		= Vec3f(0.0f);
		this->Le		= ColorXYZf(0.0f);
		this->UV		= Vec2f(0.0f);
	}

	HOST_DEVICE ScatterEvent& ScatterEvent::operator = (const ScatterEvent& Other)
	{
		this->Type			= Other.Type;
		this->Valid			= Other.Valid;	
		this->T				= Other.T;
		this->P				= Other.P;
		this->N				= Other.N;
		this->Wo			= Other.Wo;
		this->Le			= Other.Le;
		this->UV			= Other.UV;
		this->ReflectorID	= Other.ReflectorID;
		this->LightID		= Other.LightID;

		return *this;
	}
};

struct Intersection
{
	bool		Valid;
	bool		Front;
	float		NearT;
	float		FarT;
	Vec3f		P;
	Vec3f		N;
	Vec2f		UV;
	
	HOST_DEVICE Intersection()
	{
		this->SetInvalid();
	}

	HOST_DEVICE void SetValid(float NearT, Vec3f P, Vec3f N, Vec2f UV = Vec2f(0.0f))
	{
		this->Valid		= true;
		this->NearT		= NearT;
		this->P			= P;
		this->N			= N;
		this->UV		= UV;
	}

	HOST_DEVICE void SetInvalid()
	{
		this->Valid		= false;
		this->Front		= true;
		this->NearT		= 0.0f;
		this->FarT		= FLT_MAX;
		this->P			= Vec3f(0.0f);
		this->N			= Vec3f(0.0f);
		this->UV		= Vec2f(0.0f);
	}

	HOST_DEVICE Intersection& Intersection::operator = (const Intersection& Other)
	{
		this->Valid			= Other.Valid;	
		this->Front			= Other.Front;
		this->NearT			= Other.NearT;
		this->FarT			= Other.FarT;
		this->P				= Other.P;
		this->N				= Other.N;
		this->UV			= Other.UV;

		return *this;
	}
};