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

#include "VtkErLight.h"

#include <vtkSmartPointer.h>
#include <vtkTransform.h>

class VTK_ER_CORE_EXPORT vtkErAreaLight : public vtkErLight
{
public:
	vtkTypeMacro(vtkErAreaLight, vtkErLight);
	static vtkErAreaLight* New();

	vtkGetMacro(ShapeType, int);
	vtkSetMacro(ShapeType, int);

	vtkSetVector3Macro(Up, double);
	vtkGetVectorMacro(Up, double, 3);

	vtkGetVector3Macro(N, double);
	vtkGetVector3Macro(U, double);
	vtkGetVector3Macro(V, double);

	vtkGetVector3Macro(Scale, double);
	vtkSetVector3Macro(Scale, double);
	
	vtkTransform* GetTransform();

protected:
	vtkErAreaLight(void);
	virtual ~vtkErAreaLight(void);

	int								ShapeType;
	double							Up[3];
	double							N[3];
	double							U[3];
	double							V[3];
	double							Scale[3];
	vtkSmartPointer<vtkTransform>	TransformMatrix;
	vtkSmartPointer<vtkTransform>	UserTransformMatrix;
};