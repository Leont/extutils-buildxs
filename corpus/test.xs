/*
 * This software is copyright (c) 2008, 2009, 2010 by Leon Timmermans <leont@cpan.org>.
 *
 * This is free software; you can redistribute it and/or modify it under
 * the same terms as perl itself.
 *
 */
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

MODULE = corpus::test				PACKAGE = corpus::test

int
answer()
	CODE:
		XSRETURN_IV(42);
